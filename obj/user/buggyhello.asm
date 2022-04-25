
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 ca 1d 80 00       	push   $0x801dca
  800111:	6a 23                	push   $0x23
  800113:	68 e7 1d 80 00       	push   $0x801de7
  800118:	e8 21 0f 00 00       	call   80103e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 ca 1d 80 00       	push   $0x801dca
  800192:	6a 23                	push   $0x23
  800194:	68 e7 1d 80 00       	push   $0x801de7
  800199:	e8 a0 0e 00 00       	call   80103e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 ca 1d 80 00       	push   $0x801dca
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 e7 1d 80 00       	push   $0x801de7
  8001db:	e8 5e 0e 00 00       	call   80103e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 ca 1d 80 00       	push   $0x801dca
  800216:	6a 23                	push   $0x23
  800218:	68 e7 1d 80 00       	push   $0x801de7
  80021d:	e8 1c 0e 00 00       	call   80103e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 ca 1d 80 00       	push   $0x801dca
  800258:	6a 23                	push   $0x23
  80025a:	68 e7 1d 80 00       	push   $0x801de7
  80025f:	e8 da 0d 00 00       	call   80103e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 ca 1d 80 00       	push   $0x801dca
  80029a:	6a 23                	push   $0x23
  80029c:	68 e7 1d 80 00       	push   $0x801de7
  8002a1:	e8 98 0d 00 00       	call   80103e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 ca 1d 80 00       	push   $0x801dca
  8002dc:	6a 23                	push   $0x23
  8002de:	68 e7 1d 80 00       	push   $0x801de7
  8002e3:	e8 56 0d 00 00       	call   80103e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 ca 1d 80 00       	push   $0x801dca
  800340:	6a 23                	push   $0x23
  800342:	68 e7 1d 80 00       	push   $0x801de7
  800347:	e8 f2 0c 00 00       	call   80103e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 f8 1d 80 00       	push   $0x801df8
  80045b:	e8 b7 0c 00 00       	call   801117 <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 39 1e 80 00       	push   $0x801e39
  800685:	e8 8d 0a 00 00       	call   801117 <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 55 1e 80 00       	push   $0x801e55
  80075a:	e8 b8 09 00 00       	call   801117 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 18 1e 80 00       	push   $0x801e18
  80080f:	e8 03 09 00 00       	call   801117 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 e3 01 00 00       	call   800abb <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 8b 11 00 00       	call   801aaa <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 1c 11 00 00       	call   801a56 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 ba 10 00 00       	call   801a01 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 ea 0c 00 00       	call   8016ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 52 0c             	mov    0xc(%edx),%edx
  800a02:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  800a08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a0d:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a12:	0f 47 c2             	cmova  %edx,%eax
  800a15:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a1a:	50                   	push   %eax
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	68 08 50 80 00       	push   $0x805008
  800a23:	e8 24 0e 00 00       	call   80184c <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a32:	e8 cc fe ff ff       	call   800903 <fsipc>
    return r;
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 40 0c             	mov    0xc(%eax),%eax
  800a47:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5c:	e8 a2 fe ff ff       	call   800903 <fsipc>
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 4b                	js     800ab2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a67:	39 c6                	cmp    %eax,%esi
  800a69:	73 16                	jae    800a81 <devfile_read+0x48>
  800a6b:	68 84 1e 80 00       	push   $0x801e84
  800a70:	68 8b 1e 80 00       	push   $0x801e8b
  800a75:	6a 7c                	push   $0x7c
  800a77:	68 a0 1e 80 00       	push   $0x801ea0
  800a7c:	e8 bd 05 00 00       	call   80103e <_panic>
	assert(r <= PGSIZE);
  800a81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a86:	7e 16                	jle    800a9e <devfile_read+0x65>
  800a88:	68 ab 1e 80 00       	push   $0x801eab
  800a8d:	68 8b 1e 80 00       	push   $0x801e8b
  800a92:	6a 7d                	push   $0x7d
  800a94:	68 a0 1e 80 00       	push   $0x801ea0
  800a99:	e8 a0 05 00 00       	call   80103e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9e:	83 ec 04             	sub    $0x4,%esp
  800aa1:	50                   	push   %eax
  800aa2:	68 00 50 80 00       	push   $0x805000
  800aa7:	ff 75 0c             	pushl  0xc(%ebp)
  800aaa:	e8 9d 0d 00 00       	call   80184c <memmove>
	return r;
  800aaf:	83 c4 10             	add    $0x10,%esp
}
  800ab2:	89 d8                	mov    %ebx,%eax
  800ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	83 ec 20             	sub    $0x20,%esp
  800ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac5:	53                   	push   %ebx
  800ac6:	e8 b6 0b 00 00       	call   801681 <strlen>
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad3:	7f 67                	jg     800b3c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad5:	83 ec 0c             	sub    $0xc,%esp
  800ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800adb:	50                   	push   %eax
  800adc:	e8 9a f8 ff ff       	call   80037b <fd_alloc>
  800ae1:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 57                	js     800b41 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	53                   	push   %ebx
  800aee:	68 00 50 80 00       	push   $0x805000
  800af3:	e8 c2 0b 00 00       	call   8016ba <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b03:	b8 01 00 00 00       	mov    $0x1,%eax
  800b08:	e8 f6 fd ff ff       	call   800903 <fsipc>
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	85 c0                	test   %eax,%eax
  800b14:	79 14                	jns    800b2a <open+0x6f>
		fd_close(fd, 0);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	6a 00                	push   $0x0
  800b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1e:	e8 50 f9 ff ff       	call   800473 <fd_close>
		return r;
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	89 da                	mov    %ebx,%edx
  800b28:	eb 17                	jmp    800b41 <open+0x86>
	}

	return fd2num(fd);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b30:	e8 1f f8 ff ff       	call   800354 <fd2num>
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	eb 05                	jmp    800b41 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b3c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b41:	89 d0                	mov    %edx,%eax
  800b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 08 00 00 00       	mov    $0x8,%eax
  800b58:	e8 a6 fd ff ff       	call   800903 <fsipc>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	e8 f2 f7 ff ff       	call   800364 <fd2data>
  800b72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b74:	83 c4 08             	add    $0x8,%esp
  800b77:	68 b7 1e 80 00       	push   $0x801eb7
  800b7c:	53                   	push   %ebx
  800b7d:	e8 38 0b 00 00       	call   8016ba <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b82:	8b 46 04             	mov    0x4(%esi),%eax
  800b85:	2b 06                	sub    (%esi),%eax
  800b87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b94:	00 00 00 
	stat->st_dev = &devpipe;
  800b97:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b9e:	30 80 00 
	return 0;
}
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb7:	53                   	push   %ebx
  800bb8:	6a 00                	push   $0x0
  800bba:	e8 29 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bbf:	89 1c 24             	mov    %ebx,(%esp)
  800bc2:	e8 9d f7 ff ff       	call   800364 <fd2data>
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 00                	push   $0x0
  800bcd:	e8 16 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 1c             	sub    $0x1c,%esp
  800be0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be5:	a1 04 40 80 00       	mov    0x804004,%eax
  800bea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf3:	e8 eb 0e 00 00       	call   801ae3 <pageref>
  800bf8:	89 c3                	mov    %eax,%ebx
  800bfa:	89 3c 24             	mov    %edi,(%esp)
  800bfd:	e8 e1 0e 00 00       	call   801ae3 <pageref>
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	39 c3                	cmp    %eax,%ebx
  800c07:	0f 94 c1             	sete   %cl
  800c0a:	0f b6 c9             	movzbl %cl,%ecx
  800c0d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c10:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c16:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c19:	39 ce                	cmp    %ecx,%esi
  800c1b:	74 1b                	je     800c38 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c1d:	39 c3                	cmp    %eax,%ebx
  800c1f:	75 c4                	jne    800be5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c21:	8b 42 58             	mov    0x58(%edx),%eax
  800c24:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c27:	50                   	push   %eax
  800c28:	56                   	push   %esi
  800c29:	68 be 1e 80 00       	push   $0x801ebe
  800c2e:	e8 e4 04 00 00       	call   801117 <cprintf>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	eb ad                	jmp    800be5 <_pipeisclosed+0xe>
	}
}
  800c38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 28             	sub    $0x28,%esp
  800c4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4f:	56                   	push   %esi
  800c50:	e8 0f f7 ff ff       	call   800364 <fd2data>
  800c55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	eb 4b                	jmp    800cac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c61:	89 da                	mov    %ebx,%edx
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	e8 6d ff ff ff       	call   800bd7 <_pipeisclosed>
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	75 48                	jne    800cb6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c6e:	e8 d1 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c73:	8b 43 04             	mov    0x4(%ebx),%eax
  800c76:	8b 0b                	mov    (%ebx),%ecx
  800c78:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	73 e2                	jae    800c61 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c86:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c89:	89 c2                	mov    %eax,%edx
  800c8b:	c1 fa 1f             	sar    $0x1f,%edx
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	c1 e9 1b             	shr    $0x1b,%ecx
  800c93:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c96:	83 e2 1f             	and    $0x1f,%edx
  800c99:	29 ca                	sub    %ecx,%edx
  800c9b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca3:	83 c0 01             	add    $0x1,%eax
  800ca6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca9:	83 c7 01             	add    $0x1,%edi
  800cac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800caf:	75 c2                	jne    800c73 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb4:	eb 05                	jmp    800cbb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 18             	sub    $0x18,%esp
  800ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ccf:	57                   	push   %edi
  800cd0:	e8 8f f6 ff ff       	call   800364 <fd2data>
  800cd5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	eb 3d                	jmp    800d1e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce1:	85 db                	test   %ebx,%ebx
  800ce3:	74 04                	je     800ce9 <devpipe_read+0x26>
				return i;
  800ce5:	89 d8                	mov    %ebx,%eax
  800ce7:	eb 44                	jmp    800d2d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	89 f8                	mov    %edi,%eax
  800ced:	e8 e5 fe ff ff       	call   800bd7 <_pipeisclosed>
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	75 32                	jne    800d28 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf6:	e8 49 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cfb:	8b 06                	mov    (%esi),%eax
  800cfd:	3b 46 04             	cmp    0x4(%esi),%eax
  800d00:	74 df                	je     800ce1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d02:	99                   	cltd   
  800d03:	c1 ea 1b             	shr    $0x1b,%edx
  800d06:	01 d0                	add    %edx,%eax
  800d08:	83 e0 1f             	and    $0x1f,%eax
  800d0b:	29 d0                	sub    %edx,%eax
  800d0d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d18:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1b:	83 c3 01             	add    $0x1,%ebx
  800d1e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d21:	75 d8                	jne    800cfb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d23:	8b 45 10             	mov    0x10(%ebp),%eax
  800d26:	eb 05                	jmp    800d2d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d40:	50                   	push   %eax
  800d41:	e8 35 f6 ff ff       	call   80037b <fd_alloc>
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	0f 88 2c 01 00 00    	js     800e7f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 07 04 00 00       	push   $0x407
  800d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5e:	6a 00                	push   $0x0
  800d60:	e8 fe f3 ff ff       	call   800163 <sys_page_alloc>
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	0f 88 0d 01 00 00    	js     800e7f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d78:	50                   	push   %eax
  800d79:	e8 fd f5 ff ff       	call   80037b <fd_alloc>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	0f 88 e2 00 00 00    	js     800e6d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 07 04 00 00       	push   $0x407
  800d93:	ff 75 f0             	pushl  -0x10(%ebp)
  800d96:	6a 00                	push   $0x0
  800d98:	e8 c6 f3 ff ff       	call   800163 <sys_page_alloc>
  800d9d:	89 c3                	mov    %eax,%ebx
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	0f 88 c3 00 00 00    	js     800e6d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	ff 75 f4             	pushl  -0xc(%ebp)
  800db0:	e8 af f5 ff ff       	call   800364 <fd2data>
  800db5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db7:	83 c4 0c             	add    $0xc,%esp
  800dba:	68 07 04 00 00       	push   $0x407
  800dbf:	50                   	push   %eax
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 9c f3 ff ff       	call   800163 <sys_page_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 89 00 00 00    	js     800e5d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dda:	e8 85 f5 ff ff       	call   800364 <fd2data>
  800ddf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de6:	50                   	push   %eax
  800de7:	6a 00                	push   $0x0
  800de9:	56                   	push   %esi
  800dea:	6a 00                	push   $0x0
  800dec:	e8 b5 f3 ff ff       	call   8001a6 <sys_page_map>
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	83 c4 20             	add    $0x20,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 55                	js     800e4f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2a:	e8 25 f5 ff ff       	call   800354 <fd2num>
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e34:	83 c4 04             	add    $0x4,%esp
  800e37:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3a:	e8 15 f5 ff ff       	call   800354 <fd2num>
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	eb 30                	jmp    800e7f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	56                   	push   %esi
  800e53:	6a 00                	push   $0x0
  800e55:	e8 8e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e5a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	ff 75 f0             	pushl  -0x10(%ebp)
  800e63:	6a 00                	push   $0x0
  800e65:	e8 7e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e6a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	ff 75 f4             	pushl  -0xc(%ebp)
  800e73:	6a 00                	push   $0x0
  800e75:	e8 6e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 75 08             	pushl  0x8(%ebp)
  800e95:	e8 30 f5 ff ff       	call   8003ca <fd_lookup>
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 18                	js     800eb9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea7:	e8 b8 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb1:	e8 21 fd ff ff       	call   800bd7 <_pipeisclosed>
  800eb6:	83 c4 10             	add    $0x10,%esp
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ecb:	68 d6 1e 80 00       	push   $0x801ed6
  800ed0:	ff 75 0c             	pushl  0xc(%ebp)
  800ed3:	e8 e2 07 00 00       	call   8016ba <strcpy>
	return 0;
}
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef6:	eb 2d                	jmp    800f25 <devcons_write+0x46>
		m = n - tot;
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800efd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f00:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f05:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	03 45 0c             	add    0xc(%ebp),%eax
  800f0f:	50                   	push   %eax
  800f10:	57                   	push   %edi
  800f11:	e8 36 09 00 00       	call   80184c <memmove>
		sys_cputs(buf, m);
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	53                   	push   %ebx
  800f1a:	57                   	push   %edi
  800f1b:	e8 87 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f20:	01 de                	add    %ebx,%esi
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2a:	72 cc                	jb     800ef8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 08             	sub    $0x8,%esp
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f43:	74 2a                	je     800f6f <devcons_read+0x3b>
  800f45:	eb 05                	jmp    800f4c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f47:	e8 f8 f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f4c:	e8 74 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f51:	85 c0                	test   %eax,%eax
  800f53:	74 f2                	je     800f47 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 16                	js     800f6f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f59:	83 f8 04             	cmp    $0x4,%eax
  800f5c:	74 0c                	je     800f6a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f61:	88 02                	mov    %al,(%edx)
	return 1;
  800f63:	b8 01 00 00 00       	mov    $0x1,%eax
  800f68:	eb 05                	jmp    800f6f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f7d:	6a 01                	push   $0x1
  800f7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	e8 1f f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <getchar>:

int
getchar(void)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f93:	6a 01                	push   $0x1
  800f95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 90 f6 ff ff       	call   800630 <read>
	if (r < 0)
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 0f                	js     800fb6 <getchar+0x29>
		return r;
	if (r < 1)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 06                	jle    800fb1 <getchar+0x24>
		return -E_EOF;
	return c;
  800fab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800faf:	eb 05                	jmp    800fb6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	ff 75 08             	pushl  0x8(%ebp)
  800fc5:	e8 00 f4 ff ff       	call   8003ca <fd_lookup>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 11                	js     800fe2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fda:	39 10                	cmp    %edx,(%eax)
  800fdc:	0f 94 c0             	sete   %al
  800fdf:	0f b6 c0             	movzbl %al,%eax
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <opencons>:

int
opencons(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	e8 88 f3 ff ff       	call   80037b <fd_alloc>
  800ff3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 3e                	js     80103a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 07 04 00 00       	push   $0x407
  801004:	ff 75 f4             	pushl  -0xc(%ebp)
  801007:	6a 00                	push   $0x0
  801009:	e8 55 f1 ff ff       	call   800163 <sys_page_alloc>
  80100e:	83 c4 10             	add    $0x10,%esp
		return r;
  801011:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	78 23                	js     80103a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801017:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801025:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	50                   	push   %eax
  801030:	e8 1f f3 ff ff       	call   800354 <fd2num>
  801035:	89 c2                	mov    %eax,%edx
  801037:	83 c4 10             	add    $0x10,%esp
}
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801043:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801046:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104c:	e8 d4 f0 ff ff       	call   800125 <sys_getenvid>
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	ff 75 0c             	pushl  0xc(%ebp)
  801057:	ff 75 08             	pushl  0x8(%ebp)
  80105a:	56                   	push   %esi
  80105b:	50                   	push   %eax
  80105c:	68 e4 1e 80 00       	push   $0x801ee4
  801061:	e8 b1 00 00 00       	call   801117 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801066:	83 c4 18             	add    $0x18,%esp
  801069:	53                   	push   %ebx
  80106a:	ff 75 10             	pushl  0x10(%ebp)
  80106d:	e8 54 00 00 00       	call   8010c6 <vcprintf>
	cprintf("\n");
  801072:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801079:	e8 99 00 00 00       	call   801117 <cprintf>
  80107e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801081:	cc                   	int3   
  801082:	eb fd                	jmp    801081 <_panic+0x43>

00801084 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	53                   	push   %ebx
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108e:	8b 13                	mov    (%ebx),%edx
  801090:	8d 42 01             	lea    0x1(%edx),%eax
  801093:	89 03                	mov    %eax,(%ebx)
  801095:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801098:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a1:	75 1a                	jne    8010bd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	68 ff 00 00 00       	push   $0xff
  8010ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 f3 ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ba:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d6:	00 00 00 
	b.cnt = 0;
  8010d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e3:	ff 75 0c             	pushl  0xc(%ebp)
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	68 84 10 80 00       	push   $0x801084
  8010f5:	e8 54 01 00 00       	call   80124e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fa:	83 c4 08             	add    $0x8,%esp
  8010fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	e8 98 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  80110f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80111d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801120:	50                   	push   %eax
  801121:	ff 75 08             	pushl  0x8(%ebp)
  801124:	e8 9d ff ff ff       	call   8010c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 1c             	sub    $0x1c,%esp
  801134:	89 c7                	mov    %eax,%edi
  801136:	89 d6                	mov    %edx,%esi
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801141:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801144:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801152:	39 d3                	cmp    %edx,%ebx
  801154:	72 05                	jb     80115b <printnum+0x30>
  801156:	39 45 10             	cmp    %eax,0x10(%ebp)
  801159:	77 45                	ja     8011a0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	ff 75 18             	pushl  0x18(%ebp)
  801161:	8b 45 14             	mov    0x14(%ebp),%eax
  801164:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801167:	53                   	push   %ebx
  801168:	ff 75 10             	pushl  0x10(%ebp)
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801171:	ff 75 e0             	pushl  -0x20(%ebp)
  801174:	ff 75 dc             	pushl  -0x24(%ebp)
  801177:	ff 75 d8             	pushl  -0x28(%ebp)
  80117a:	e8 a1 09 00 00       	call   801b20 <__udivdi3>
  80117f:	83 c4 18             	add    $0x18,%esp
  801182:	52                   	push   %edx
  801183:	50                   	push   %eax
  801184:	89 f2                	mov    %esi,%edx
  801186:	89 f8                	mov    %edi,%eax
  801188:	e8 9e ff ff ff       	call   80112b <printnum>
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	eb 18                	jmp    8011aa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	56                   	push   %esi
  801196:	ff 75 18             	pushl  0x18(%ebp)
  801199:	ff d7                	call   *%edi
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	eb 03                	jmp    8011a3 <printnum+0x78>
  8011a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a3:	83 eb 01             	sub    $0x1,%ebx
  8011a6:	85 db                	test   %ebx,%ebx
  8011a8:	7f e8                	jg     801192 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	56                   	push   %esi
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bd:	e8 8e 0a 00 00       	call   801c50 <__umoddi3>
  8011c2:	83 c4 14             	add    $0x14,%esp
  8011c5:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011cc:	50                   	push   %eax
  8011cd:	ff d7                	call   *%edi
}
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011dd:	83 fa 01             	cmp    $0x1,%edx
  8011e0:	7e 0e                	jle    8011f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011e2:	8b 10                	mov    (%eax),%edx
  8011e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e7:	89 08                	mov    %ecx,(%eax)
  8011e9:	8b 02                	mov    (%edx),%eax
  8011eb:	8b 52 04             	mov    0x4(%edx),%edx
  8011ee:	eb 22                	jmp    801212 <getuint+0x38>
	else if (lflag)
  8011f0:	85 d2                	test   %edx,%edx
  8011f2:	74 10                	je     801204 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011f4:	8b 10                	mov    (%eax),%edx
  8011f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f9:	89 08                	mov    %ecx,(%eax)
  8011fb:	8b 02                	mov    (%edx),%eax
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801202:	eb 0e                	jmp    801212 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801204:	8b 10                	mov    (%eax),%edx
  801206:	8d 4a 04             	lea    0x4(%edx),%ecx
  801209:	89 08                	mov    %ecx,(%eax)
  80120b:	8b 02                	mov    (%edx),%eax
  80120d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80121a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	3b 50 04             	cmp    0x4(%eax),%edx
  801223:	73 0a                	jae    80122f <sprintputch+0x1b>
		*b->buf++ = ch;
  801225:	8d 4a 01             	lea    0x1(%edx),%ecx
  801228:	89 08                	mov    %ecx,(%eax)
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	88 02                	mov    %al,(%edx)
}
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801237:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80123a:	50                   	push   %eax
  80123b:	ff 75 10             	pushl  0x10(%ebp)
  80123e:	ff 75 0c             	pushl  0xc(%ebp)
  801241:	ff 75 08             	pushl  0x8(%ebp)
  801244:	e8 05 00 00 00       	call   80124e <vprintfmt>
	va_end(ap);
}
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	57                   	push   %edi
  801252:	56                   	push   %esi
  801253:	53                   	push   %ebx
  801254:	83 ec 2c             	sub    $0x2c,%esp
  801257:	8b 75 08             	mov    0x8(%ebp),%esi
  80125a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80125d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801260:	eb 12                	jmp    801274 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801262:	85 c0                	test   %eax,%eax
  801264:	0f 84 a7 03 00 00    	je     801611 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	53                   	push   %ebx
  80126e:	50                   	push   %eax
  80126f:	ff d6                	call   *%esi
  801271:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801274:	83 c7 01             	add    $0x1,%edi
  801277:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80127b:	83 f8 25             	cmp    $0x25,%eax
  80127e:	75 e2                	jne    801262 <vprintfmt+0x14>
  801280:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801284:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80128b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801299:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a5:	eb 07                	jmp    8012ae <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ae:	8d 47 01             	lea    0x1(%edi),%eax
  8012b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b4:	0f b6 07             	movzbl (%edi),%eax
  8012b7:	0f b6 d0             	movzbl %al,%edx
  8012ba:	83 e8 23             	sub    $0x23,%eax
  8012bd:	3c 55                	cmp    $0x55,%al
  8012bf:	0f 87 31 03 00 00    	ja     8015f6 <vprintfmt+0x3a8>
  8012c5:	0f b6 c0             	movzbl %al,%eax
  8012c8:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8012cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012d6:	eb d6                	jmp    8012ae <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e0:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012e6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012ea:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012ed:	8d 72 d0             	lea    -0x30(%edx),%esi
  8012f0:	83 fe 09             	cmp    $0x9,%esi
  8012f3:	77 34                	ja     801329 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f8:	eb e9                	jmp    8012e3 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fd:	8d 50 04             	lea    0x4(%eax),%edx
  801300:	89 55 14             	mov    %edx,0x14(%ebp)
  801303:	8b 00                	mov    (%eax),%eax
  801305:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80130b:	eb 22                	jmp    80132f <vprintfmt+0xe1>
  80130d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801310:	85 c0                	test   %eax,%eax
  801312:	0f 48 c1             	cmovs  %ecx,%eax
  801315:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131b:	eb 91                	jmp    8012ae <vprintfmt+0x60>
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801320:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801327:	eb 85                	jmp    8012ae <vprintfmt+0x60>
  801329:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80132c:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80132f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801333:	0f 89 75 ff ff ff    	jns    8012ae <vprintfmt+0x60>
				width = precision, precision = -1;
  801339:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80133c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801346:	e9 63 ff ff ff       	jmp    8012ae <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80134b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801352:	e9 57 ff ff ff       	jmp    8012ae <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801357:	8b 45 14             	mov    0x14(%ebp),%eax
  80135a:	8d 50 04             	lea    0x4(%eax),%edx
  80135d:	89 55 14             	mov    %edx,0x14(%ebp)
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	53                   	push   %ebx
  801364:	ff 30                	pushl  (%eax)
  801366:	ff d6                	call   *%esi
			break;
  801368:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80136e:	e9 01 ff ff ff       	jmp    801274 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801373:	8b 45 14             	mov    0x14(%ebp),%eax
  801376:	8d 50 04             	lea    0x4(%eax),%edx
  801379:	89 55 14             	mov    %edx,0x14(%ebp)
  80137c:	8b 00                	mov    (%eax),%eax
  80137e:	99                   	cltd   
  80137f:	31 d0                	xor    %edx,%eax
  801381:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801383:	83 f8 0f             	cmp    $0xf,%eax
  801386:	7f 0b                	jg     801393 <vprintfmt+0x145>
  801388:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  80138f:	85 d2                	test   %edx,%edx
  801391:	75 18                	jne    8013ab <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  801393:	50                   	push   %eax
  801394:	68 1f 1f 80 00       	push   $0x801f1f
  801399:	53                   	push   %ebx
  80139a:	56                   	push   %esi
  80139b:	e8 91 fe ff ff       	call   801231 <printfmt>
  8013a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a6:	e9 c9 fe ff ff       	jmp    801274 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ab:	52                   	push   %edx
  8013ac:	68 9d 1e 80 00       	push   $0x801e9d
  8013b1:	53                   	push   %ebx
  8013b2:	56                   	push   %esi
  8013b3:	e8 79 fe ff ff       	call   801231 <printfmt>
  8013b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013be:	e9 b1 fe ff ff       	jmp    801274 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c6:	8d 50 04             	lea    0x4(%eax),%edx
  8013c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8013cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013ce:	85 ff                	test   %edi,%edi
  8013d0:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013dc:	0f 8e 94 00 00 00    	jle    801476 <vprintfmt+0x228>
  8013e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e6:	0f 84 98 00 00 00    	je     801484 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	ff 75 cc             	pushl  -0x34(%ebp)
  8013f2:	57                   	push   %edi
  8013f3:	e8 a1 02 00 00       	call   801699 <strnlen>
  8013f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013fb:	29 c1                	sub    %eax,%ecx
  8013fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801400:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801403:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80140d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140f:	eb 0f                	jmp    801420 <vprintfmt+0x1d2>
					putch(padc, putdat);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	53                   	push   %ebx
  801415:	ff 75 e0             	pushl  -0x20(%ebp)
  801418:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141a:	83 ef 01             	sub    $0x1,%edi
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	85 ff                	test   %edi,%edi
  801422:	7f ed                	jg     801411 <vprintfmt+0x1c3>
  801424:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801427:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80142a:	85 c9                	test   %ecx,%ecx
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	0f 49 c1             	cmovns %ecx,%eax
  801434:	29 c1                	sub    %eax,%ecx
  801436:	89 75 08             	mov    %esi,0x8(%ebp)
  801439:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80143c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80143f:	89 cb                	mov    %ecx,%ebx
  801441:	eb 4d                	jmp    801490 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801443:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801447:	74 1b                	je     801464 <vprintfmt+0x216>
  801449:	0f be c0             	movsbl %al,%eax
  80144c:	83 e8 20             	sub    $0x20,%eax
  80144f:	83 f8 5e             	cmp    $0x5e,%eax
  801452:	76 10                	jbe    801464 <vprintfmt+0x216>
					putch('?', putdat);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	6a 3f                	push   $0x3f
  80145c:	ff 55 08             	call   *0x8(%ebp)
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb 0d                	jmp    801471 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	ff 75 0c             	pushl  0xc(%ebp)
  80146a:	52                   	push   %edx
  80146b:	ff 55 08             	call   *0x8(%ebp)
  80146e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801471:	83 eb 01             	sub    $0x1,%ebx
  801474:	eb 1a                	jmp    801490 <vprintfmt+0x242>
  801476:	89 75 08             	mov    %esi,0x8(%ebp)
  801479:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80147c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801482:	eb 0c                	jmp    801490 <vprintfmt+0x242>
  801484:	89 75 08             	mov    %esi,0x8(%ebp)
  801487:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80148a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801490:	83 c7 01             	add    $0x1,%edi
  801493:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801497:	0f be d0             	movsbl %al,%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	74 23                	je     8014c1 <vprintfmt+0x273>
  80149e:	85 f6                	test   %esi,%esi
  8014a0:	78 a1                	js     801443 <vprintfmt+0x1f5>
  8014a2:	83 ee 01             	sub    $0x1,%esi
  8014a5:	79 9c                	jns    801443 <vprintfmt+0x1f5>
  8014a7:	89 df                	mov    %ebx,%edi
  8014a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014af:	eb 18                	jmp    8014c9 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	6a 20                	push   $0x20
  8014b7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b9:	83 ef 01             	sub    $0x1,%edi
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	eb 08                	jmp    8014c9 <vprintfmt+0x27b>
  8014c1:	89 df                	mov    %ebx,%edi
  8014c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c9:	85 ff                	test   %edi,%edi
  8014cb:	7f e4                	jg     8014b1 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d0:	e9 9f fd ff ff       	jmp    801274 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014d5:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014d9:	7e 16                	jle    8014f1 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8d 50 08             	lea    0x8(%eax),%edx
  8014e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e4:	8b 50 04             	mov    0x4(%eax),%edx
  8014e7:	8b 00                	mov    (%eax),%eax
  8014e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ef:	eb 34                	jmp    801525 <vprintfmt+0x2d7>
	else if (lflag)
  8014f1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014f5:	74 18                	je     80150f <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8d 50 04             	lea    0x4(%eax),%edx
  8014fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801500:	8b 00                	mov    (%eax),%eax
  801502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801505:	89 c1                	mov    %eax,%ecx
  801507:	c1 f9 1f             	sar    $0x1f,%ecx
  80150a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80150d:	eb 16                	jmp    801525 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80150f:	8b 45 14             	mov    0x14(%ebp),%eax
  801512:	8d 50 04             	lea    0x4(%eax),%edx
  801515:	89 55 14             	mov    %edx,0x14(%ebp)
  801518:	8b 00                	mov    (%eax),%eax
  80151a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151d:	89 c1                	mov    %eax,%ecx
  80151f:	c1 f9 1f             	sar    $0x1f,%ecx
  801522:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801525:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801528:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80152b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801530:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801534:	0f 89 88 00 00 00    	jns    8015c2 <vprintfmt+0x374>
				putch('-', putdat);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	53                   	push   %ebx
  80153e:	6a 2d                	push   $0x2d
  801540:	ff d6                	call   *%esi
				num = -(long long) num;
  801542:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801545:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801548:	f7 d8                	neg    %eax
  80154a:	83 d2 00             	adc    $0x0,%edx
  80154d:	f7 da                	neg    %edx
  80154f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801552:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801557:	eb 69                	jmp    8015c2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801559:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80155c:	8d 45 14             	lea    0x14(%ebp),%eax
  80155f:	e8 76 fc ff ff       	call   8011da <getuint>
			base = 10;
  801564:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801569:	eb 57                	jmp    8015c2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	53                   	push   %ebx
  80156f:	6a 30                	push   $0x30
  801571:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  801573:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801576:	8d 45 14             	lea    0x14(%ebp),%eax
  801579:	e8 5c fc ff ff       	call   8011da <getuint>
			base = 8;
			goto number;
  80157e:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801581:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801586:	eb 3a                	jmp    8015c2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	6a 30                	push   $0x30
  80158e:	ff d6                	call   *%esi
			putch('x', putdat);
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	53                   	push   %ebx
  801594:	6a 78                	push   $0x78
  801596:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8d 50 04             	lea    0x4(%eax),%edx
  80159e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a1:	8b 00                	mov    (%eax),%eax
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b0:	eb 10                	jmp    8015c2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b2:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b8:	e8 1d fc ff ff       	call   8011da <getuint>
			base = 16;
  8015bd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c9:	57                   	push   %edi
  8015ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cd:	51                   	push   %ecx
  8015ce:	52                   	push   %edx
  8015cf:	50                   	push   %eax
  8015d0:	89 da                	mov    %ebx,%edx
  8015d2:	89 f0                	mov    %esi,%eax
  8015d4:	e8 52 fb ff ff       	call   80112b <printnum>
			break;
  8015d9:	83 c4 20             	add    $0x20,%esp
  8015dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015df:	e9 90 fc ff ff       	jmp    801274 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	52                   	push   %edx
  8015e9:	ff d6                	call   *%esi
			break;
  8015eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f1:	e9 7e fc ff ff       	jmp    801274 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	53                   	push   %ebx
  8015fa:	6a 25                	push   $0x25
  8015fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb 03                	jmp    801606 <vprintfmt+0x3b8>
  801603:	83 ef 01             	sub    $0x1,%edi
  801606:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80160a:	75 f7                	jne    801603 <vprintfmt+0x3b5>
  80160c:	e9 63 fc ff ff       	jmp    801274 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801611:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801614:	5b                   	pop    %ebx
  801615:	5e                   	pop    %esi
  801616:	5f                   	pop    %edi
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 18             	sub    $0x18,%esp
  80161f:	8b 45 08             	mov    0x8(%ebp),%eax
  801622:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801625:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801628:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801636:	85 c0                	test   %eax,%eax
  801638:	74 26                	je     801660 <vsnprintf+0x47>
  80163a:	85 d2                	test   %edx,%edx
  80163c:	7e 22                	jle    801660 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163e:	ff 75 14             	pushl  0x14(%ebp)
  801641:	ff 75 10             	pushl  0x10(%ebp)
  801644:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	68 14 12 80 00       	push   $0x801214
  80164d:	e8 fc fb ff ff       	call   80124e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801652:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801655:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801658:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	eb 05                	jmp    801665 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801660:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801665:	c9                   	leave  
  801666:	c3                   	ret    

00801667 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801670:	50                   	push   %eax
  801671:	ff 75 10             	pushl  0x10(%ebp)
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	ff 75 08             	pushl  0x8(%ebp)
  80167a:	e8 9a ff ff ff       	call   801619 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
  80168c:	eb 03                	jmp    801691 <strlen+0x10>
		n++;
  80168e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801691:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801695:	75 f7                	jne    80168e <strlen+0xd>
		n++;
	return n;
}
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a7:	eb 03                	jmp    8016ac <strnlen+0x13>
		n++;
  8016a9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ac:	39 c2                	cmp    %eax,%edx
  8016ae:	74 08                	je     8016b8 <strnlen+0x1f>
  8016b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b4:	75 f3                	jne    8016a9 <strnlen+0x10>
  8016b6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	83 c2 01             	add    $0x1,%edx
  8016c9:	83 c1 01             	add    $0x1,%ecx
  8016cc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d3:	84 db                	test   %bl,%bl
  8016d5:	75 ef                	jne    8016c6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d7:	5b                   	pop    %ebx
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e1:	53                   	push   %ebx
  8016e2:	e8 9a ff ff ff       	call   801681 <strlen>
  8016e7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	01 d8                	add    %ebx,%eax
  8016ef:	50                   	push   %eax
  8016f0:	e8 c5 ff ff ff       	call   8016ba <strcpy>
	return dst;
}
  8016f5:	89 d8                	mov    %ebx,%eax
  8016f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	8b 75 08             	mov    0x8(%ebp),%esi
  801704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801707:	89 f3                	mov    %esi,%ebx
  801709:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170c:	89 f2                	mov    %esi,%edx
  80170e:	eb 0f                	jmp    80171f <strncpy+0x23>
		*dst++ = *src;
  801710:	83 c2 01             	add    $0x1,%edx
  801713:	0f b6 01             	movzbl (%ecx),%eax
  801716:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801719:	80 39 01             	cmpb   $0x1,(%ecx)
  80171c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171f:	39 da                	cmp    %ebx,%edx
  801721:	75 ed                	jne    801710 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801723:	89 f0                	mov    %esi,%eax
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	8b 75 08             	mov    0x8(%ebp),%esi
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	8b 55 10             	mov    0x10(%ebp),%edx
  801737:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801739:	85 d2                	test   %edx,%edx
  80173b:	74 21                	je     80175e <strlcpy+0x35>
  80173d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801741:	89 f2                	mov    %esi,%edx
  801743:	eb 09                	jmp    80174e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801745:	83 c2 01             	add    $0x1,%edx
  801748:	83 c1 01             	add    $0x1,%ecx
  80174b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80174e:	39 c2                	cmp    %eax,%edx
  801750:	74 09                	je     80175b <strlcpy+0x32>
  801752:	0f b6 19             	movzbl (%ecx),%ebx
  801755:	84 db                	test   %bl,%bl
  801757:	75 ec                	jne    801745 <strlcpy+0x1c>
  801759:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80175b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175e:	29 f0                	sub    %esi,%eax
}
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176d:	eb 06                	jmp    801775 <strcmp+0x11>
		p++, q++;
  80176f:	83 c1 01             	add    $0x1,%ecx
  801772:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801775:	0f b6 01             	movzbl (%ecx),%eax
  801778:	84 c0                	test   %al,%al
  80177a:	74 04                	je     801780 <strcmp+0x1c>
  80177c:	3a 02                	cmp    (%edx),%al
  80177e:	74 ef                	je     80176f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801780:	0f b6 c0             	movzbl %al,%eax
  801783:	0f b6 12             	movzbl (%edx),%edx
  801786:	29 d0                	sub    %edx,%eax
}
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8b 55 0c             	mov    0xc(%ebp),%edx
  801794:	89 c3                	mov    %eax,%ebx
  801796:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801799:	eb 06                	jmp    8017a1 <strncmp+0x17>
		n--, p++, q++;
  80179b:	83 c0 01             	add    $0x1,%eax
  80179e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a1:	39 d8                	cmp    %ebx,%eax
  8017a3:	74 15                	je     8017ba <strncmp+0x30>
  8017a5:	0f b6 08             	movzbl (%eax),%ecx
  8017a8:	84 c9                	test   %cl,%cl
  8017aa:	74 04                	je     8017b0 <strncmp+0x26>
  8017ac:	3a 0a                	cmp    (%edx),%cl
  8017ae:	74 eb                	je     80179b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b0:	0f b6 00             	movzbl (%eax),%eax
  8017b3:	0f b6 12             	movzbl (%edx),%edx
  8017b6:	29 d0                	sub    %edx,%eax
  8017b8:	eb 05                	jmp    8017bf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017bf:	5b                   	pop    %ebx
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017cc:	eb 07                	jmp    8017d5 <strchr+0x13>
		if (*s == c)
  8017ce:	38 ca                	cmp    %cl,%dl
  8017d0:	74 0f                	je     8017e1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d2:	83 c0 01             	add    $0x1,%eax
  8017d5:	0f b6 10             	movzbl (%eax),%edx
  8017d8:	84 d2                	test   %dl,%dl
  8017da:	75 f2                	jne    8017ce <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ed:	eb 03                	jmp    8017f2 <strfind+0xf>
  8017ef:	83 c0 01             	add    $0x1,%eax
  8017f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f5:	38 ca                	cmp    %cl,%dl
  8017f7:	74 04                	je     8017fd <strfind+0x1a>
  8017f9:	84 d2                	test   %dl,%dl
  8017fb:	75 f2                	jne    8017ef <strfind+0xc>
			break;
	return (char *) s;
}
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	57                   	push   %edi
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	8b 7d 08             	mov    0x8(%ebp),%edi
  801808:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80180b:	85 c9                	test   %ecx,%ecx
  80180d:	74 36                	je     801845 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801815:	75 28                	jne    80183f <memset+0x40>
  801817:	f6 c1 03             	test   $0x3,%cl
  80181a:	75 23                	jne    80183f <memset+0x40>
		c &= 0xFF;
  80181c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801820:	89 d3                	mov    %edx,%ebx
  801822:	c1 e3 08             	shl    $0x8,%ebx
  801825:	89 d6                	mov    %edx,%esi
  801827:	c1 e6 18             	shl    $0x18,%esi
  80182a:	89 d0                	mov    %edx,%eax
  80182c:	c1 e0 10             	shl    $0x10,%eax
  80182f:	09 f0                	or     %esi,%eax
  801831:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801833:	89 d8                	mov    %ebx,%eax
  801835:	09 d0                	or     %edx,%eax
  801837:	c1 e9 02             	shr    $0x2,%ecx
  80183a:	fc                   	cld    
  80183b:	f3 ab                	rep stos %eax,%es:(%edi)
  80183d:	eb 06                	jmp    801845 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801842:	fc                   	cld    
  801843:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801845:	89 f8                	mov    %edi,%eax
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5f                   	pop    %edi
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	57                   	push   %edi
  801850:	56                   	push   %esi
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	8b 75 0c             	mov    0xc(%ebp),%esi
  801857:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185a:	39 c6                	cmp    %eax,%esi
  80185c:	73 35                	jae    801893 <memmove+0x47>
  80185e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801861:	39 d0                	cmp    %edx,%eax
  801863:	73 2e                	jae    801893 <memmove+0x47>
		s += n;
		d += n;
  801865:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801868:	89 d6                	mov    %edx,%esi
  80186a:	09 fe                	or     %edi,%esi
  80186c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801872:	75 13                	jne    801887 <memmove+0x3b>
  801874:	f6 c1 03             	test   $0x3,%cl
  801877:	75 0e                	jne    801887 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801879:	83 ef 04             	sub    $0x4,%edi
  80187c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187f:	c1 e9 02             	shr    $0x2,%ecx
  801882:	fd                   	std    
  801883:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801885:	eb 09                	jmp    801890 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801887:	83 ef 01             	sub    $0x1,%edi
  80188a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80188d:	fd                   	std    
  80188e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801890:	fc                   	cld    
  801891:	eb 1d                	jmp    8018b0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801893:	89 f2                	mov    %esi,%edx
  801895:	09 c2                	or     %eax,%edx
  801897:	f6 c2 03             	test   $0x3,%dl
  80189a:	75 0f                	jne    8018ab <memmove+0x5f>
  80189c:	f6 c1 03             	test   $0x3,%cl
  80189f:	75 0a                	jne    8018ab <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018a1:	c1 e9 02             	shr    $0x2,%ecx
  8018a4:	89 c7                	mov    %eax,%edi
  8018a6:	fc                   	cld    
  8018a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a9:	eb 05                	jmp    8018b0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ab:	89 c7                	mov    %eax,%edi
  8018ad:	fc                   	cld    
  8018ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b0:	5e                   	pop    %esi
  8018b1:	5f                   	pop    %edi
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    

008018b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b7:	ff 75 10             	pushl  0x10(%ebp)
  8018ba:	ff 75 0c             	pushl  0xc(%ebp)
  8018bd:	ff 75 08             	pushl  0x8(%ebp)
  8018c0:	e8 87 ff ff ff       	call   80184c <memmove>
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d2:	89 c6                	mov    %eax,%esi
  8018d4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d7:	eb 1a                	jmp    8018f3 <memcmp+0x2c>
		if (*s1 != *s2)
  8018d9:	0f b6 08             	movzbl (%eax),%ecx
  8018dc:	0f b6 1a             	movzbl (%edx),%ebx
  8018df:	38 d9                	cmp    %bl,%cl
  8018e1:	74 0a                	je     8018ed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e3:	0f b6 c1             	movzbl %cl,%eax
  8018e6:	0f b6 db             	movzbl %bl,%ebx
  8018e9:	29 d8                	sub    %ebx,%eax
  8018eb:	eb 0f                	jmp    8018fc <memcmp+0x35>
		s1++, s2++;
  8018ed:	83 c0 01             	add    $0x1,%eax
  8018f0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f3:	39 f0                	cmp    %esi,%eax
  8018f5:	75 e2                	jne    8018d9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	53                   	push   %ebx
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801907:	89 c1                	mov    %eax,%ecx
  801909:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80190c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801910:	eb 0a                	jmp    80191c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801912:	0f b6 10             	movzbl (%eax),%edx
  801915:	39 da                	cmp    %ebx,%edx
  801917:	74 07                	je     801920 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801919:	83 c0 01             	add    $0x1,%eax
  80191c:	39 c8                	cmp    %ecx,%eax
  80191e:	72 f2                	jb     801912 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801920:	5b                   	pop    %ebx
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	57                   	push   %edi
  801927:	56                   	push   %esi
  801928:	53                   	push   %ebx
  801929:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192f:	eb 03                	jmp    801934 <strtol+0x11>
		s++;
  801931:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801934:	0f b6 01             	movzbl (%ecx),%eax
  801937:	3c 20                	cmp    $0x20,%al
  801939:	74 f6                	je     801931 <strtol+0xe>
  80193b:	3c 09                	cmp    $0x9,%al
  80193d:	74 f2                	je     801931 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193f:	3c 2b                	cmp    $0x2b,%al
  801941:	75 0a                	jne    80194d <strtol+0x2a>
		s++;
  801943:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801946:	bf 00 00 00 00       	mov    $0x0,%edi
  80194b:	eb 11                	jmp    80195e <strtol+0x3b>
  80194d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801952:	3c 2d                	cmp    $0x2d,%al
  801954:	75 08                	jne    80195e <strtol+0x3b>
		s++, neg = 1;
  801956:	83 c1 01             	add    $0x1,%ecx
  801959:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801964:	75 15                	jne    80197b <strtol+0x58>
  801966:	80 39 30             	cmpb   $0x30,(%ecx)
  801969:	75 10                	jne    80197b <strtol+0x58>
  80196b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196f:	75 7c                	jne    8019ed <strtol+0xca>
		s += 2, base = 16;
  801971:	83 c1 02             	add    $0x2,%ecx
  801974:	bb 10 00 00 00       	mov    $0x10,%ebx
  801979:	eb 16                	jmp    801991 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80197b:	85 db                	test   %ebx,%ebx
  80197d:	75 12                	jne    801991 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801984:	80 39 30             	cmpb   $0x30,(%ecx)
  801987:	75 08                	jne    801991 <strtol+0x6e>
		s++, base = 8;
  801989:	83 c1 01             	add    $0x1,%ecx
  80198c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801999:	0f b6 11             	movzbl (%ecx),%edx
  80199c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199f:	89 f3                	mov    %esi,%ebx
  8019a1:	80 fb 09             	cmp    $0x9,%bl
  8019a4:	77 08                	ja     8019ae <strtol+0x8b>
			dig = *s - '0';
  8019a6:	0f be d2             	movsbl %dl,%edx
  8019a9:	83 ea 30             	sub    $0x30,%edx
  8019ac:	eb 22                	jmp    8019d0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019ae:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b1:	89 f3                	mov    %esi,%ebx
  8019b3:	80 fb 19             	cmp    $0x19,%bl
  8019b6:	77 08                	ja     8019c0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019b8:	0f be d2             	movsbl %dl,%edx
  8019bb:	83 ea 57             	sub    $0x57,%edx
  8019be:	eb 10                	jmp    8019d0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019c0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c3:	89 f3                	mov    %esi,%ebx
  8019c5:	80 fb 19             	cmp    $0x19,%bl
  8019c8:	77 16                	ja     8019e0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019ca:	0f be d2             	movsbl %dl,%edx
  8019cd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d3:	7d 0b                	jge    8019e0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019d5:	83 c1 01             	add    $0x1,%ecx
  8019d8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019dc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019de:	eb b9                	jmp    801999 <strtol+0x76>

	if (endptr)
  8019e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e4:	74 0d                	je     8019f3 <strtol+0xd0>
		*endptr = (char *) s;
  8019e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e9:	89 0e                	mov    %ecx,(%esi)
  8019eb:	eb 06                	jmp    8019f3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ed:	85 db                	test   %ebx,%ebx
  8019ef:	74 98                	je     801989 <strtol+0x66>
  8019f1:	eb 9e                	jmp    801991 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	f7 da                	neg    %edx
  8019f7:	85 ff                	test   %edi,%edi
  8019f9:	0f 45 c2             	cmovne %edx,%eax
}
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5f                   	pop    %edi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	8b 75 08             	mov    0x8(%ebp),%esi
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a16:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	50                   	push   %eax
  801a1d:	e8 f1 e8 ff ff       	call   800313 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	75 10                	jne    801a39 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a29:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2e:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a31:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a34:	8b 40 70             	mov    0x70(%eax),%eax
  801a37:	eb 0a                	jmp    801a43 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a3e:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a43:	85 f6                	test   %esi,%esi
  801a45:	74 02                	je     801a49 <ipc_recv+0x48>
  801a47:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a49:	85 db                	test   %ebx,%ebx
  801a4b:	74 02                	je     801a4f <ipc_recv+0x4e>
  801a4d:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a52:	5b                   	pop    %ebx
  801a53:	5e                   	pop    %esi
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	57                   	push   %edi
  801a5a:	56                   	push   %esi
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a6f:	0f 44 d8             	cmove  %eax,%ebx
  801a72:	eb 1c                	jmp    801a90 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a74:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a77:	74 12                	je     801a8b <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a79:	50                   	push   %eax
  801a7a:	68 00 22 80 00       	push   $0x802200
  801a7f:	6a 40                	push   $0x40
  801a81:	68 12 22 80 00       	push   $0x802212
  801a86:	e8 b3 f5 ff ff       	call   80103e <_panic>
        sys_yield();
  801a8b:	e8 b4 e6 ff ff       	call   800144 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a90:	ff 75 14             	pushl  0x14(%ebp)
  801a93:	53                   	push   %ebx
  801a94:	56                   	push   %esi
  801a95:	57                   	push   %edi
  801a96:	e8 55 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 d2                	jne    801a74 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ab8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801abe:	8b 52 50             	mov    0x50(%edx),%edx
  801ac1:	39 ca                	cmp    %ecx,%edx
  801ac3:	75 0d                	jne    801ad2 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ac5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801acd:	8b 40 48             	mov    0x48(%eax),%eax
  801ad0:	eb 0f                	jmp    801ae1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad2:	83 c0 01             	add    $0x1,%eax
  801ad5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ada:	75 d9                	jne    801ab5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae9:	89 d0                	mov    %edx,%eax
  801aeb:	c1 e8 16             	shr    $0x16,%eax
  801aee:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afa:	f6 c1 01             	test   $0x1,%cl
  801afd:	74 1d                	je     801b1c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801aff:	c1 ea 0c             	shr    $0xc,%edx
  801b02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b09:	f6 c2 01             	test   $0x1,%dl
  801b0c:	74 0e                	je     801b1c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0e:	c1 ea 0c             	shr    $0xc,%edx
  801b11:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b18:	ef 
  801b19:	0f b7 c0             	movzwl %ax,%eax
}
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    
  801b1e:	66 90                	xchg   %ax,%ax

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
