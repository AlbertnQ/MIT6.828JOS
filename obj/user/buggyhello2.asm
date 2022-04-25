
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 d8 1d 80 00       	push   $0x801dd8
  800118:	6a 23                	push   $0x23
  80011a:	68 f5 1d 80 00       	push   $0x801df5
  80011f:	e8 21 0f 00 00       	call   801045 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 d8 1d 80 00       	push   $0x801dd8
  800199:	6a 23                	push   $0x23
  80019b:	68 f5 1d 80 00       	push   $0x801df5
  8001a0:	e8 a0 0e 00 00       	call   801045 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 d8 1d 80 00       	push   $0x801dd8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 f5 1d 80 00       	push   $0x801df5
  8001e2:	e8 5e 0e 00 00       	call   801045 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 d8 1d 80 00       	push   $0x801dd8
  80021d:	6a 23                	push   $0x23
  80021f:	68 f5 1d 80 00       	push   $0x801df5
  800224:	e8 1c 0e 00 00       	call   801045 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 d8 1d 80 00       	push   $0x801dd8
  80025f:	6a 23                	push   $0x23
  800261:	68 f5 1d 80 00       	push   $0x801df5
  800266:	e8 da 0d 00 00       	call   801045 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 d8 1d 80 00       	push   $0x801dd8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 f5 1d 80 00       	push   $0x801df5
  8002a8:	e8 98 0d 00 00       	call   801045 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 d8 1d 80 00       	push   $0x801dd8
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 f5 1d 80 00       	push   $0x801df5
  8002ea:	e8 56 0d 00 00       	call   801045 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 d8 1d 80 00       	push   $0x801dd8
  800347:	6a 23                	push   $0x23
  800349:	68 f5 1d 80 00       	push   $0x801df5
  80034e:	e8 f2 0c 00 00       	call   801045 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba 80 1e 80 00       	mov    $0x801e80,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 04 1e 80 00       	push   $0x801e04
  800462:	e8 b7 0c 00 00       	call   80111e <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 45 1e 80 00       	push   $0x801e45
  80068c:	e8 8d 0a 00 00       	call   80111e <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 61 1e 80 00       	push   $0x801e61
  800761:	e8 b8 09 00 00       	call   80111e <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 24 1e 80 00       	push   $0x801e24
  800816:	e8 03 09 00 00       	call   80111e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 e3 01 00 00       	call   800ac2 <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 8b 11 00 00       	call   801ab1 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 1c 11 00 00       	call   801a5d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 ba 10 00 00       	call   801a08 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 ea 0c 00 00       	call   8016c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
  800a06:	8b 52 0c             	mov    0xc(%edx),%edx
  800a09:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  800a0f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a14:	ba 00 10 00 00       	mov    $0x1000,%edx
  800a19:	0f 47 c2             	cmova  %edx,%eax
  800a1c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a21:	50                   	push   %eax
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	68 08 50 80 00       	push   $0x805008
  800a2a:	e8 24 0e 00 00       	call   801853 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 04 00 00 00       	mov    $0x4,%eax
  800a39:	e8 cc fe ff ff       	call   80090a <fsipc>
    return r;
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a63:	e8 a2 fe ff ff       	call   80090a <fsipc>
  800a68:	89 c3                	mov    %eax,%ebx
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	78 4b                	js     800ab9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6e:	39 c6                	cmp    %eax,%esi
  800a70:	73 16                	jae    800a88 <devfile_read+0x48>
  800a72:	68 90 1e 80 00       	push   $0x801e90
  800a77:	68 97 1e 80 00       	push   $0x801e97
  800a7c:	6a 7c                	push   $0x7c
  800a7e:	68 ac 1e 80 00       	push   $0x801eac
  800a83:	e8 bd 05 00 00       	call   801045 <_panic>
	assert(r <= PGSIZE);
  800a88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8d:	7e 16                	jle    800aa5 <devfile_read+0x65>
  800a8f:	68 b7 1e 80 00       	push   $0x801eb7
  800a94:	68 97 1e 80 00       	push   $0x801e97
  800a99:	6a 7d                	push   $0x7d
  800a9b:	68 ac 1e 80 00       	push   $0x801eac
  800aa0:	e8 a0 05 00 00       	call   801045 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa5:	83 ec 04             	sub    $0x4,%esp
  800aa8:	50                   	push   %eax
  800aa9:	68 00 50 80 00       	push   $0x805000
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	e8 9d 0d 00 00       	call   801853 <memmove>
	return r;
  800ab6:	83 c4 10             	add    $0x10,%esp
}
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 20             	sub    $0x20,%esp
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800acc:	53                   	push   %ebx
  800acd:	e8 b6 0b 00 00       	call   801688 <strlen>
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ada:	7f 67                	jg     800b43 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 9a f8 ff ff       	call   800382 <fd_alloc>
  800ae8:	83 c4 10             	add    $0x10,%esp
		return r;
  800aeb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aed:	85 c0                	test   %eax,%eax
  800aef:	78 57                	js     800b48 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	53                   	push   %ebx
  800af5:	68 00 50 80 00       	push   $0x805000
  800afa:	e8 c2 0b 00 00       	call   8016c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	e8 f6 fd ff ff       	call   80090a <fsipc>
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	79 14                	jns    800b31 <open+0x6f>
		fd_close(fd, 0);
  800b1d:	83 ec 08             	sub    $0x8,%esp
  800b20:	6a 00                	push   $0x0
  800b22:	ff 75 f4             	pushl  -0xc(%ebp)
  800b25:	e8 50 f9 ff ff       	call   80047a <fd_close>
		return r;
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	89 da                	mov    %ebx,%edx
  800b2f:	eb 17                	jmp    800b48 <open+0x86>
	}

	return fd2num(fd);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 1f f8 ff ff       	call   80035b <fd2num>
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	eb 05                	jmp    800b48 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b43:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b48:	89 d0                	mov    %edx,%eax
  800b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5f:	e8 a6 fd ff ff       	call   80090a <fsipc>
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	ff 75 08             	pushl  0x8(%ebp)
  800b74:	e8 f2 f7 ff ff       	call   80036b <fd2data>
  800b79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7b:	83 c4 08             	add    $0x8,%esp
  800b7e:	68 c3 1e 80 00       	push   $0x801ec3
  800b83:	53                   	push   %ebx
  800b84:	e8 38 0b 00 00       	call   8016c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b89:	8b 46 04             	mov    0x4(%esi),%eax
  800b8c:	2b 06                	sub    (%esi),%eax
  800b8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9b:	00 00 00 
	stat->st_dev = &devpipe;
  800b9e:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800ba5:	30 80 00 
	return 0;
}
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbe:	53                   	push   %ebx
  800bbf:	6a 00                	push   $0x0
  800bc1:	e8 29 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc6:	89 1c 24             	mov    %ebx,(%esp)
  800bc9:	e8 9d f7 ff ff       	call   80036b <fd2data>
  800bce:	83 c4 08             	add    $0x8,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 00                	push   $0x0
  800bd4:	e8 16 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bea:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bec:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bfa:	e8 eb 0e 00 00       	call   801aea <pageref>
  800bff:	89 c3                	mov    %eax,%ebx
  800c01:	89 3c 24             	mov    %edi,(%esp)
  800c04:	e8 e1 0e 00 00       	call   801aea <pageref>
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	39 c3                	cmp    %eax,%ebx
  800c0e:	0f 94 c1             	sete   %cl
  800c11:	0f b6 c9             	movzbl %cl,%ecx
  800c14:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c17:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c20:	39 ce                	cmp    %ecx,%esi
  800c22:	74 1b                	je     800c3f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c24:	39 c3                	cmp    %eax,%ebx
  800c26:	75 c4                	jne    800bec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c28:	8b 42 58             	mov    0x58(%edx),%eax
  800c2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2e:	50                   	push   %eax
  800c2f:	56                   	push   %esi
  800c30:	68 ca 1e 80 00       	push   $0x801eca
  800c35:	e8 e4 04 00 00       	call   80111e <cprintf>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb ad                	jmp    800bec <_pipeisclosed+0xe>
	}
}
  800c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 28             	sub    $0x28,%esp
  800c53:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c56:	56                   	push   %esi
  800c57:	e8 0f f7 ff ff       	call   80036b <fd2data>
  800c5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
  800c66:	eb 4b                	jmp    800cb3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c68:	89 da                	mov    %ebx,%edx
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	e8 6d ff ff ff       	call   800bde <_pipeisclosed>
  800c71:	85 c0                	test   %eax,%eax
  800c73:	75 48                	jne    800cbd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c75:	e8 d1 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7d:	8b 0b                	mov    (%ebx),%ecx
  800c7f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c82:	39 d0                	cmp    %edx,%eax
  800c84:	73 e2                	jae    800c68 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	c1 fa 1f             	sar    $0x1f,%edx
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9d:	83 e2 1f             	and    $0x1f,%edx
  800ca0:	29 ca                	sub    %ecx,%edx
  800ca2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb0:	83 c7 01             	add    $0x1,%edi
  800cb3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb6:	75 c2                	jne    800c7a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbb:	eb 05                	jmp    800cc2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 18             	sub    $0x18,%esp
  800cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd6:	57                   	push   %edi
  800cd7:	e8 8f f6 ff ff       	call   80036b <fd2data>
  800cdc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cde:	83 c4 10             	add    $0x10,%esp
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	eb 3d                	jmp    800d25 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce8:	85 db                	test   %ebx,%ebx
  800cea:	74 04                	je     800cf0 <devpipe_read+0x26>
				return i;
  800cec:	89 d8                	mov    %ebx,%eax
  800cee:	eb 44                	jmp    800d34 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf0:	89 f2                	mov    %esi,%edx
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	e8 e5 fe ff ff       	call   800bde <_pipeisclosed>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	75 32                	jne    800d2f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cfd:	e8 49 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d02:	8b 06                	mov    (%esi),%eax
  800d04:	3b 46 04             	cmp    0x4(%esi),%eax
  800d07:	74 df                	je     800ce8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d09:	99                   	cltd   
  800d0a:	c1 ea 1b             	shr    $0x1b,%edx
  800d0d:	01 d0                	add    %edx,%eax
  800d0f:	83 e0 1f             	and    $0x1f,%eax
  800d12:	29 d0                	sub    %edx,%eax
  800d14:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c3 01             	add    $0x1,%ebx
  800d25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d28:	75 d8                	jne    800d02 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2d:	eb 05                	jmp    800d34 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 35 f6 ff ff       	call   800382 <fd_alloc>
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	85 c0                	test   %eax,%eax
  800d54:	0f 88 2c 01 00 00    	js     800e86 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 04 00 00       	push   $0x407
  800d62:	ff 75 f4             	pushl  -0xc(%ebp)
  800d65:	6a 00                	push   $0x0
  800d67:	e8 fe f3 ff ff       	call   80016a <sys_page_alloc>
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 0d 01 00 00    	js     800e86 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 fd f5 ff ff       	call   800382 <fd_alloc>
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 e2 00 00 00    	js     800e74 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 c6 f3 ff ff       	call   80016a <sys_page_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 c3 00 00 00    	js     800e74 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	ff 75 f4             	pushl  -0xc(%ebp)
  800db7:	e8 af f5 ff ff       	call   80036b <fd2data>
  800dbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbe:	83 c4 0c             	add    $0xc,%esp
  800dc1:	68 07 04 00 00       	push   $0x407
  800dc6:	50                   	push   %eax
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 9c f3 ff ff       	call   80016a <sys_page_alloc>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	0f 88 89 00 00 00    	js     800e64 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	ff 75 f0             	pushl  -0x10(%ebp)
  800de1:	e8 85 f5 ff ff       	call   80036b <fd2data>
  800de6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ded:	50                   	push   %eax
  800dee:	6a 00                	push   $0x0
  800df0:	56                   	push   %esi
  800df1:	6a 00                	push   $0x0
  800df3:	e8 b5 f3 ff ff       	call   8001ad <sys_page_map>
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	83 c4 20             	add    $0x20,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	78 55                	js     800e56 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e16:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e31:	e8 25 f5 ff ff       	call   80035b <fd2num>
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3b:	83 c4 04             	add    $0x4,%esp
  800e3e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e41:	e8 15 f5 ff ff       	call   80035b <fd2num>
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	eb 30                	jmp    800e86 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	56                   	push   %esi
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 8e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e61:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 7e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 6e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	ff 75 08             	pushl  0x8(%ebp)
  800e9c:	e8 30 f5 ff ff       	call   8003d1 <fd_lookup>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 18                	js     800ec0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 b8 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb8:	e8 21 fd ff ff       	call   800bde <_pipeisclosed>
  800ebd:	83 c4 10             	add    $0x10,%esp
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed2:	68 e2 1e 80 00       	push   $0x801ee2
  800ed7:	ff 75 0c             	pushl  0xc(%ebp)
  800eda:	e8 e2 07 00 00       	call   8016c1 <strcpy>
	return 0;
}
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efd:	eb 2d                	jmp    800f2c <devcons_write+0x46>
		m = n - tot;
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f04:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f07:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f0c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	53                   	push   %ebx
  800f13:	03 45 0c             	add    0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	57                   	push   %edi
  800f18:	e8 36 09 00 00       	call   801853 <memmove>
		sys_cputs(buf, m);
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	53                   	push   %ebx
  800f21:	57                   	push   %edi
  800f22:	e8 87 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f27:	01 de                	add    %ebx,%esi
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f31:	72 cc                	jb     800eff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4a:	74 2a                	je     800f76 <devcons_read+0x3b>
  800f4c:	eb 05                	jmp    800f53 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4e:	e8 f8 f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f53:	e8 74 f1 ff ff       	call   8000cc <sys_cgetc>
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	74 f2                	je     800f4e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 16                	js     800f76 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f60:	83 f8 04             	cmp    $0x4,%eax
  800f63:	74 0c                	je     800f71 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f68:	88 02                	mov    %al,(%edx)
	return 1;
  800f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6f:	eb 05                	jmp    800f76 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f84:	6a 01                	push   $0x1
  800f86:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	e8 1f f1 ff ff       	call   8000ae <sys_cputs>
}
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <getchar>:

int
getchar(void)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f9a:	6a 01                	push   $0x1
  800f9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 90 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 0f                	js     800fbd <getchar+0x29>
		return r;
	if (r < 1)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 06                	jle    800fb8 <getchar+0x24>
		return -E_EOF;
	return c;
  800fb2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb6:	eb 05                	jmp    800fbd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 00 f4 ff ff       	call   8003d1 <fd_lookup>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 11                	js     800fe9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fe1:	39 10                	cmp    %edx,(%eax)
  800fe3:	0f 94 c0             	sete   %al
  800fe6:	0f b6 c0             	movzbl %al,%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <opencons>:

int
opencons(void)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	e8 88 f3 ff ff       	call   800382 <fd_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
		return r;
  800ffd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 3e                	js     801041 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 07 04 00 00       	push   $0x407
  80100b:	ff 75 f4             	pushl  -0xc(%ebp)
  80100e:	6a 00                	push   $0x0
  801010:	e8 55 f1 ff ff       	call   80016a <sys_page_alloc>
  801015:	83 c4 10             	add    $0x10,%esp
		return r;
  801018:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 23                	js     801041 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	50                   	push   %eax
  801037:	e8 1f f3 ff ff       	call   80035b <fd2num>
  80103c:	89 c2                	mov    %eax,%edx
  80103e:	83 c4 10             	add    $0x10,%esp
}
  801041:	89 d0                	mov    %edx,%eax
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801053:	e8 d4 f0 ff ff       	call   80012c <sys_getenvid>
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	ff 75 08             	pushl  0x8(%ebp)
  801061:	56                   	push   %esi
  801062:	50                   	push   %eax
  801063:	68 f0 1e 80 00       	push   $0x801ef0
  801068:	e8 b1 00 00 00       	call   80111e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106d:	83 c4 18             	add    $0x18,%esp
  801070:	53                   	push   %ebx
  801071:	ff 75 10             	pushl  0x10(%ebp)
  801074:	e8 54 00 00 00       	call   8010cd <vcprintf>
	cprintf("\n");
  801079:	c7 04 24 db 1e 80 00 	movl   $0x801edb,(%esp)
  801080:	e8 99 00 00 00       	call   80111e <cprintf>
  801085:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801088:	cc                   	int3   
  801089:	eb fd                	jmp    801088 <_panic+0x43>

0080108b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	83 ec 04             	sub    $0x4,%esp
  801092:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801095:	8b 13                	mov    (%ebx),%edx
  801097:	8d 42 01             	lea    0x1(%edx),%eax
  80109a:	89 03                	mov    %eax,(%ebx)
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a8:	75 1a                	jne    8010c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	68 ff 00 00 00       	push   $0xff
  8010b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b5:	50                   	push   %eax
  8010b6:	e8 f3 ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    

008010cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010dd:	00 00 00 
	b.cnt = 0;
  8010e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ea:	ff 75 0c             	pushl  0xc(%ebp)
  8010ed:	ff 75 08             	pushl  0x8(%ebp)
  8010f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	68 8b 10 80 00       	push   $0x80108b
  8010fc:	e8 54 01 00 00       	call   801255 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80110a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	e8 98 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801116:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801124:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801127:	50                   	push   %eax
  801128:	ff 75 08             	pushl  0x8(%ebp)
  80112b:	e8 9d ff ff ff       	call   8010cd <vcprintf>
	va_end(ap);

	return cnt;
}
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 1c             	sub    $0x1c,%esp
  80113b:	89 c7                	mov    %eax,%edi
  80113d:	89 d6                	mov    %edx,%esi
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	8b 55 0c             	mov    0xc(%ebp),%edx
  801145:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801148:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80114b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801156:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801159:	39 d3                	cmp    %edx,%ebx
  80115b:	72 05                	jb     801162 <printnum+0x30>
  80115d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801160:	77 45                	ja     8011a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	ff 75 18             	pushl  0x18(%ebp)
  801168:	8b 45 14             	mov    0x14(%ebp),%eax
  80116b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116e:	53                   	push   %ebx
  80116f:	ff 75 10             	pushl  0x10(%ebp)
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	ff 75 e4             	pushl  -0x1c(%ebp)
  801178:	ff 75 e0             	pushl  -0x20(%ebp)
  80117b:	ff 75 dc             	pushl  -0x24(%ebp)
  80117e:	ff 75 d8             	pushl  -0x28(%ebp)
  801181:	e8 aa 09 00 00       	call   801b30 <__udivdi3>
  801186:	83 c4 18             	add    $0x18,%esp
  801189:	52                   	push   %edx
  80118a:	50                   	push   %eax
  80118b:	89 f2                	mov    %esi,%edx
  80118d:	89 f8                	mov    %edi,%eax
  80118f:	e8 9e ff ff ff       	call   801132 <printnum>
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	eb 18                	jmp    8011b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	56                   	push   %esi
  80119d:	ff 75 18             	pushl  0x18(%ebp)
  8011a0:	ff d7                	call   *%edi
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb 03                	jmp    8011aa <printnum+0x78>
  8011a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011aa:	83 eb 01             	sub    $0x1,%ebx
  8011ad:	85 db                	test   %ebx,%ebx
  8011af:	7f e8                	jg     801199 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	56                   	push   %esi
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011be:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c4:	e8 97 0a 00 00       	call   801c60 <__umoddi3>
  8011c9:	83 c4 14             	add    $0x14,%esp
  8011cc:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff d7                	call   *%edi
}
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e4:	83 fa 01             	cmp    $0x1,%edx
  8011e7:	7e 0e                	jle    8011f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011e9:	8b 10                	mov    (%eax),%edx
  8011eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ee:	89 08                	mov    %ecx,(%eax)
  8011f0:	8b 02                	mov    (%edx),%eax
  8011f2:	8b 52 04             	mov    0x4(%edx),%edx
  8011f5:	eb 22                	jmp    801219 <getuint+0x38>
	else if (lflag)
  8011f7:	85 d2                	test   %edx,%edx
  8011f9:	74 10                	je     80120b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011fb:	8b 10                	mov    (%eax),%edx
  8011fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  801200:	89 08                	mov    %ecx,(%eax)
  801202:	8b 02                	mov    (%edx),%eax
  801204:	ba 00 00 00 00       	mov    $0x0,%edx
  801209:	eb 0e                	jmp    801219 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80120b:	8b 10                	mov    (%eax),%edx
  80120d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801210:	89 08                	mov    %ecx,(%eax)
  801212:	8b 02                	mov    (%edx),%eax
  801214:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801221:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801225:	8b 10                	mov    (%eax),%edx
  801227:	3b 50 04             	cmp    0x4(%eax),%edx
  80122a:	73 0a                	jae    801236 <sprintputch+0x1b>
		*b->buf++ = ch;
  80122c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80122f:	89 08                	mov    %ecx,(%eax)
  801231:	8b 45 08             	mov    0x8(%ebp),%eax
  801234:	88 02                	mov    %al,(%edx)
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801241:	50                   	push   %eax
  801242:	ff 75 10             	pushl  0x10(%ebp)
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 05 00 00 00       	call   801255 <vprintfmt>
	va_end(ap);
}
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 2c             	sub    $0x2c,%esp
  80125e:	8b 75 08             	mov    0x8(%ebp),%esi
  801261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801264:	8b 7d 10             	mov    0x10(%ebp),%edi
  801267:	eb 12                	jmp    80127b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801269:	85 c0                	test   %eax,%eax
  80126b:	0f 84 a7 03 00 00    	je     801618 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	53                   	push   %ebx
  801275:	50                   	push   %eax
  801276:	ff d6                	call   *%esi
  801278:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80127b:	83 c7 01             	add    $0x1,%edi
  80127e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801282:	83 f8 25             	cmp    $0x25,%eax
  801285:	75 e2                	jne    801269 <vprintfmt+0x14>
  801287:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80128b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801292:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801299:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012a0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ac:	eb 07                	jmp    8012b5 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b5:	8d 47 01             	lea    0x1(%edi),%eax
  8012b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bb:	0f b6 07             	movzbl (%edi),%eax
  8012be:	0f b6 d0             	movzbl %al,%edx
  8012c1:	83 e8 23             	sub    $0x23,%eax
  8012c4:	3c 55                	cmp    $0x55,%al
  8012c6:	0f 87 31 03 00 00    	ja     8015fd <vprintfmt+0x3a8>
  8012cc:	0f b6 c0             	movzbl %al,%eax
  8012cf:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012dd:	eb d6                	jmp    8012b5 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e7:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ea:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ed:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012f1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8012f7:	83 fe 09             	cmp    $0x9,%esi
  8012fa:	77 34                	ja     801330 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012fc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ff:	eb e9                	jmp    8012ea <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801301:	8b 45 14             	mov    0x14(%ebp),%eax
  801304:	8d 50 04             	lea    0x4(%eax),%edx
  801307:	89 55 14             	mov    %edx,0x14(%ebp)
  80130a:	8b 00                	mov    (%eax),%eax
  80130c:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801312:	eb 22                	jmp    801336 <vprintfmt+0xe1>
  801314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801317:	85 c0                	test   %eax,%eax
  801319:	0f 48 c1             	cmovs  %ecx,%eax
  80131c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801322:	eb 91                	jmp    8012b5 <vprintfmt+0x60>
  801324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801327:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80132e:	eb 85                	jmp    8012b5 <vprintfmt+0x60>
  801330:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801333:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  801336:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133a:	0f 89 75 ff ff ff    	jns    8012b5 <vprintfmt+0x60>
				width = precision, precision = -1;
  801340:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801343:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801346:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80134d:	e9 63 ff ff ff       	jmp    8012b5 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801352:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801359:	e9 57 ff ff ff       	jmp    8012b5 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80135e:	8b 45 14             	mov    0x14(%ebp),%eax
  801361:	8d 50 04             	lea    0x4(%eax),%edx
  801364:	89 55 14             	mov    %edx,0x14(%ebp)
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	53                   	push   %ebx
  80136b:	ff 30                	pushl  (%eax)
  80136d:	ff d6                	call   *%esi
			break;
  80136f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801375:	e9 01 ff ff ff       	jmp    80127b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80137a:	8b 45 14             	mov    0x14(%ebp),%eax
  80137d:	8d 50 04             	lea    0x4(%eax),%edx
  801380:	89 55 14             	mov    %edx,0x14(%ebp)
  801383:	8b 00                	mov    (%eax),%eax
  801385:	99                   	cltd   
  801386:	31 d0                	xor    %edx,%eax
  801388:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80138a:	83 f8 0f             	cmp    $0xf,%eax
  80138d:	7f 0b                	jg     80139a <vprintfmt+0x145>
  80138f:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801396:	85 d2                	test   %edx,%edx
  801398:	75 18                	jne    8013b2 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80139a:	50                   	push   %eax
  80139b:	68 2b 1f 80 00       	push   $0x801f2b
  8013a0:	53                   	push   %ebx
  8013a1:	56                   	push   %esi
  8013a2:	e8 91 fe ff ff       	call   801238 <printfmt>
  8013a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ad:	e9 c9 fe ff ff       	jmp    80127b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013b2:	52                   	push   %edx
  8013b3:	68 a9 1e 80 00       	push   $0x801ea9
  8013b8:	53                   	push   %ebx
  8013b9:	56                   	push   %esi
  8013ba:	e8 79 fe ff ff       	call   801238 <printfmt>
  8013bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c5:	e9 b1 fe ff ff       	jmp    80127b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cd:	8d 50 04             	lea    0x4(%eax),%edx
  8013d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013d5:	85 ff                	test   %edi,%edi
  8013d7:	b8 24 1f 80 00       	mov    $0x801f24,%eax
  8013dc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013e3:	0f 8e 94 00 00 00    	jle    80147d <vprintfmt+0x228>
  8013e9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ed:	0f 84 98 00 00 00    	je     80148b <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 cc             	pushl  -0x34(%ebp)
  8013f9:	57                   	push   %edi
  8013fa:	e8 a1 02 00 00       	call   8016a0 <strnlen>
  8013ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801402:	29 c1                	sub    %eax,%ecx
  801404:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801407:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80140a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80140e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801411:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801414:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801416:	eb 0f                	jmp    801427 <vprintfmt+0x1d2>
					putch(padc, putdat);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	53                   	push   %ebx
  80141c:	ff 75 e0             	pushl  -0x20(%ebp)
  80141f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801421:	83 ef 01             	sub    $0x1,%edi
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 ff                	test   %edi,%edi
  801429:	7f ed                	jg     801418 <vprintfmt+0x1c3>
  80142b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80142e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801431:	85 c9                	test   %ecx,%ecx
  801433:	b8 00 00 00 00       	mov    $0x0,%eax
  801438:	0f 49 c1             	cmovns %ecx,%eax
  80143b:	29 c1                	sub    %eax,%ecx
  80143d:	89 75 08             	mov    %esi,0x8(%ebp)
  801440:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801443:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801446:	89 cb                	mov    %ecx,%ebx
  801448:	eb 4d                	jmp    801497 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80144a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80144e:	74 1b                	je     80146b <vprintfmt+0x216>
  801450:	0f be c0             	movsbl %al,%eax
  801453:	83 e8 20             	sub    $0x20,%eax
  801456:	83 f8 5e             	cmp    $0x5e,%eax
  801459:	76 10                	jbe    80146b <vprintfmt+0x216>
					putch('?', putdat);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	ff 75 0c             	pushl  0xc(%ebp)
  801461:	6a 3f                	push   $0x3f
  801463:	ff 55 08             	call   *0x8(%ebp)
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	eb 0d                	jmp    801478 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	ff 75 0c             	pushl  0xc(%ebp)
  801471:	52                   	push   %edx
  801472:	ff 55 08             	call   *0x8(%ebp)
  801475:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801478:	83 eb 01             	sub    $0x1,%ebx
  80147b:	eb 1a                	jmp    801497 <vprintfmt+0x242>
  80147d:	89 75 08             	mov    %esi,0x8(%ebp)
  801480:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801489:	eb 0c                	jmp    801497 <vprintfmt+0x242>
  80148b:	89 75 08             	mov    %esi,0x8(%ebp)
  80148e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801491:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801494:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801497:	83 c7 01             	add    $0x1,%edi
  80149a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80149e:	0f be d0             	movsbl %al,%edx
  8014a1:	85 d2                	test   %edx,%edx
  8014a3:	74 23                	je     8014c8 <vprintfmt+0x273>
  8014a5:	85 f6                	test   %esi,%esi
  8014a7:	78 a1                	js     80144a <vprintfmt+0x1f5>
  8014a9:	83 ee 01             	sub    $0x1,%esi
  8014ac:	79 9c                	jns    80144a <vprintfmt+0x1f5>
  8014ae:	89 df                	mov    %ebx,%edi
  8014b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b6:	eb 18                	jmp    8014d0 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	6a 20                	push   $0x20
  8014be:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c0:	83 ef 01             	sub    $0x1,%edi
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	eb 08                	jmp    8014d0 <vprintfmt+0x27b>
  8014c8:	89 df                	mov    %ebx,%edi
  8014ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8014cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d0:	85 ff                	test   %edi,%edi
  8014d2:	7f e4                	jg     8014b8 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d7:	e9 9f fd ff ff       	jmp    80127b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014dc:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8014e0:	7e 16                	jle    8014f8 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8d 50 08             	lea    0x8(%eax),%edx
  8014e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014eb:	8b 50 04             	mov    0x4(%eax),%edx
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f6:	eb 34                	jmp    80152c <vprintfmt+0x2d7>
	else if (lflag)
  8014f8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014fc:	74 18                	je     801516 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8014fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801501:	8d 50 04             	lea    0x4(%eax),%edx
  801504:	89 55 14             	mov    %edx,0x14(%ebp)
  801507:	8b 00                	mov    (%eax),%eax
  801509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150c:	89 c1                	mov    %eax,%ecx
  80150e:	c1 f9 1f             	sar    $0x1f,%ecx
  801511:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801514:	eb 16                	jmp    80152c <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  801516:	8b 45 14             	mov    0x14(%ebp),%eax
  801519:	8d 50 04             	lea    0x4(%eax),%edx
  80151c:	89 55 14             	mov    %edx,0x14(%ebp)
  80151f:	8b 00                	mov    (%eax),%eax
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	89 c1                	mov    %eax,%ecx
  801526:	c1 f9 1f             	sar    $0x1f,%ecx
  801529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80152c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80152f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801532:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801537:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80153b:	0f 89 88 00 00 00    	jns    8015c9 <vprintfmt+0x374>
				putch('-', putdat);
  801541:	83 ec 08             	sub    $0x8,%esp
  801544:	53                   	push   %ebx
  801545:	6a 2d                	push   $0x2d
  801547:	ff d6                	call   *%esi
				num = -(long long) num;
  801549:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80154f:	f7 d8                	neg    %eax
  801551:	83 d2 00             	adc    $0x0,%edx
  801554:	f7 da                	neg    %edx
  801556:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801559:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80155e:	eb 69                	jmp    8015c9 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801560:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801563:	8d 45 14             	lea    0x14(%ebp),%eax
  801566:	e8 76 fc ff ff       	call   8011e1 <getuint>
			base = 10;
  80156b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801570:	eb 57                	jmp    8015c9 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	53                   	push   %ebx
  801576:	6a 30                	push   $0x30
  801578:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80157a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80157d:	8d 45 14             	lea    0x14(%ebp),%eax
  801580:	e8 5c fc ff ff       	call   8011e1 <getuint>
			base = 8;
			goto number;
  801585:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801588:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80158d:	eb 3a                	jmp    8015c9 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	53                   	push   %ebx
  801593:	6a 30                	push   $0x30
  801595:	ff d6                	call   *%esi
			putch('x', putdat);
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	6a 78                	push   $0x78
  80159d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	8d 50 04             	lea    0x4(%eax),%edx
  8015a5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a8:	8b 00                	mov    (%eax),%eax
  8015aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015af:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b7:	eb 10                	jmp    8015c9 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8015bf:	e8 1d fc ff ff       	call   8011e1 <getuint>
			base = 16;
  8015c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d0:	57                   	push   %edi
  8015d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d4:	51                   	push   %ecx
  8015d5:	52                   	push   %edx
  8015d6:	50                   	push   %eax
  8015d7:	89 da                	mov    %ebx,%edx
  8015d9:	89 f0                	mov    %esi,%eax
  8015db:	e8 52 fb ff ff       	call   801132 <printnum>
			break;
  8015e0:	83 c4 20             	add    $0x20,%esp
  8015e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e6:	e9 90 fc ff ff       	jmp    80127b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	52                   	push   %edx
  8015f0:	ff d6                	call   *%esi
			break;
  8015f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f8:	e9 7e fc ff ff       	jmp    80127b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	53                   	push   %ebx
  801601:	6a 25                	push   $0x25
  801603:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	eb 03                	jmp    80160d <vprintfmt+0x3b8>
  80160a:	83 ef 01             	sub    $0x1,%edi
  80160d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801611:	75 f7                	jne    80160a <vprintfmt+0x3b5>
  801613:	e9 63 fc ff ff       	jmp    80127b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 18             	sub    $0x18,%esp
  801626:	8b 45 08             	mov    0x8(%ebp),%eax
  801629:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80162c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801633:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80163d:	85 c0                	test   %eax,%eax
  80163f:	74 26                	je     801667 <vsnprintf+0x47>
  801641:	85 d2                	test   %edx,%edx
  801643:	7e 22                	jle    801667 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801645:	ff 75 14             	pushl  0x14(%ebp)
  801648:	ff 75 10             	pushl  0x10(%ebp)
  80164b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	68 1b 12 80 00       	push   $0x80121b
  801654:	e8 fc fb ff ff       	call   801255 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801659:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80165c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 05                	jmp    80166c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801674:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801677:	50                   	push   %eax
  801678:	ff 75 10             	pushl  0x10(%ebp)
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 9a ff ff ff       	call   801620 <vsnprintf>
	va_end(ap);

	return rc;
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
  801693:	eb 03                	jmp    801698 <strlen+0x10>
		n++;
  801695:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801698:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169c:	75 f7                	jne    801695 <strlen+0xd>
		n++;
	return n;
}
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	eb 03                	jmp    8016b3 <strnlen+0x13>
		n++;
  8016b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b3:	39 c2                	cmp    %eax,%edx
  8016b5:	74 08                	je     8016bf <strnlen+0x1f>
  8016b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016bb:	75 f3                	jne    8016b0 <strnlen+0x10>
  8016bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	83 c2 01             	add    $0x1,%edx
  8016d0:	83 c1 01             	add    $0x1,%ecx
  8016d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016da:	84 db                	test   %bl,%bl
  8016dc:	75 ef                	jne    8016cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016de:	5b                   	pop    %ebx
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e8:	53                   	push   %ebx
  8016e9:	e8 9a ff ff ff       	call   801688 <strlen>
  8016ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	01 d8                	add    %ebx,%eax
  8016f6:	50                   	push   %eax
  8016f7:	e8 c5 ff ff ff       	call   8016c1 <strcpy>
	return dst;
}
  8016fc:	89 d8                	mov    %ebx,%eax
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	8b 75 08             	mov    0x8(%ebp),%esi
  80170b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170e:	89 f3                	mov    %esi,%ebx
  801710:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801713:	89 f2                	mov    %esi,%edx
  801715:	eb 0f                	jmp    801726 <strncpy+0x23>
		*dst++ = *src;
  801717:	83 c2 01             	add    $0x1,%edx
  80171a:	0f b6 01             	movzbl (%ecx),%eax
  80171d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801720:	80 39 01             	cmpb   $0x1,(%ecx)
  801723:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801726:	39 da                	cmp    %ebx,%edx
  801728:	75 ed                	jne    801717 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80172a:	89 f0                	mov    %esi,%eax
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	8b 75 08             	mov    0x8(%ebp),%esi
  801738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173b:	8b 55 10             	mov    0x10(%ebp),%edx
  80173e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801740:	85 d2                	test   %edx,%edx
  801742:	74 21                	je     801765 <strlcpy+0x35>
  801744:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801748:	89 f2                	mov    %esi,%edx
  80174a:	eb 09                	jmp    801755 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80174c:	83 c2 01             	add    $0x1,%edx
  80174f:	83 c1 01             	add    $0x1,%ecx
  801752:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801755:	39 c2                	cmp    %eax,%edx
  801757:	74 09                	je     801762 <strlcpy+0x32>
  801759:	0f b6 19             	movzbl (%ecx),%ebx
  80175c:	84 db                	test   %bl,%bl
  80175e:	75 ec                	jne    80174c <strlcpy+0x1c>
  801760:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801762:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801765:	29 f0                	sub    %esi,%eax
}
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801771:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801774:	eb 06                	jmp    80177c <strcmp+0x11>
		p++, q++;
  801776:	83 c1 01             	add    $0x1,%ecx
  801779:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80177c:	0f b6 01             	movzbl (%ecx),%eax
  80177f:	84 c0                	test   %al,%al
  801781:	74 04                	je     801787 <strcmp+0x1c>
  801783:	3a 02                	cmp    (%edx),%al
  801785:	74 ef                	je     801776 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801787:	0f b6 c0             	movzbl %al,%eax
  80178a:	0f b6 12             	movzbl (%edx),%edx
  80178d:	29 d0                	sub    %edx,%eax
}
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	53                   	push   %ebx
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a0:	eb 06                	jmp    8017a8 <strncmp+0x17>
		n--, p++, q++;
  8017a2:	83 c0 01             	add    $0x1,%eax
  8017a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a8:	39 d8                	cmp    %ebx,%eax
  8017aa:	74 15                	je     8017c1 <strncmp+0x30>
  8017ac:	0f b6 08             	movzbl (%eax),%ecx
  8017af:	84 c9                	test   %cl,%cl
  8017b1:	74 04                	je     8017b7 <strncmp+0x26>
  8017b3:	3a 0a                	cmp    (%edx),%cl
  8017b5:	74 eb                	je     8017a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b7:	0f b6 00             	movzbl (%eax),%eax
  8017ba:	0f b6 12             	movzbl (%edx),%edx
  8017bd:	29 d0                	sub    %edx,%eax
  8017bf:	eb 05                	jmp    8017c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c6:	5b                   	pop    %ebx
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d3:	eb 07                	jmp    8017dc <strchr+0x13>
		if (*s == c)
  8017d5:	38 ca                	cmp    %cl,%dl
  8017d7:	74 0f                	je     8017e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d9:	83 c0 01             	add    $0x1,%eax
  8017dc:	0f b6 10             	movzbl (%eax),%edx
  8017df:	84 d2                	test   %dl,%dl
  8017e1:	75 f2                	jne    8017d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f4:	eb 03                	jmp    8017f9 <strfind+0xf>
  8017f6:	83 c0 01             	add    $0x1,%eax
  8017f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017fc:	38 ca                	cmp    %cl,%dl
  8017fe:	74 04                	je     801804 <strfind+0x1a>
  801800:	84 d2                	test   %dl,%dl
  801802:	75 f2                	jne    8017f6 <strfind+0xc>
			break;
	return (char *) s;
}
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	57                   	push   %edi
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801812:	85 c9                	test   %ecx,%ecx
  801814:	74 36                	je     80184c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801816:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80181c:	75 28                	jne    801846 <memset+0x40>
  80181e:	f6 c1 03             	test   $0x3,%cl
  801821:	75 23                	jne    801846 <memset+0x40>
		c &= 0xFF;
  801823:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801827:	89 d3                	mov    %edx,%ebx
  801829:	c1 e3 08             	shl    $0x8,%ebx
  80182c:	89 d6                	mov    %edx,%esi
  80182e:	c1 e6 18             	shl    $0x18,%esi
  801831:	89 d0                	mov    %edx,%eax
  801833:	c1 e0 10             	shl    $0x10,%eax
  801836:	09 f0                	or     %esi,%eax
  801838:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	09 d0                	or     %edx,%eax
  80183e:	c1 e9 02             	shr    $0x2,%ecx
  801841:	fc                   	cld    
  801842:	f3 ab                	rep stos %eax,%es:(%edi)
  801844:	eb 06                	jmp    80184c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801846:	8b 45 0c             	mov    0xc(%ebp),%eax
  801849:	fc                   	cld    
  80184a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80184c:	89 f8                	mov    %edi,%eax
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5f                   	pop    %edi
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801861:	39 c6                	cmp    %eax,%esi
  801863:	73 35                	jae    80189a <memmove+0x47>
  801865:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801868:	39 d0                	cmp    %edx,%eax
  80186a:	73 2e                	jae    80189a <memmove+0x47>
		s += n;
		d += n;
  80186c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186f:	89 d6                	mov    %edx,%esi
  801871:	09 fe                	or     %edi,%esi
  801873:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801879:	75 13                	jne    80188e <memmove+0x3b>
  80187b:	f6 c1 03             	test   $0x3,%cl
  80187e:	75 0e                	jne    80188e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801880:	83 ef 04             	sub    $0x4,%edi
  801883:	8d 72 fc             	lea    -0x4(%edx),%esi
  801886:	c1 e9 02             	shr    $0x2,%ecx
  801889:	fd                   	std    
  80188a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188c:	eb 09                	jmp    801897 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188e:	83 ef 01             	sub    $0x1,%edi
  801891:	8d 72 ff             	lea    -0x1(%edx),%esi
  801894:	fd                   	std    
  801895:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801897:	fc                   	cld    
  801898:	eb 1d                	jmp    8018b7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189a:	89 f2                	mov    %esi,%edx
  80189c:	09 c2                	or     %eax,%edx
  80189e:	f6 c2 03             	test   $0x3,%dl
  8018a1:	75 0f                	jne    8018b2 <memmove+0x5f>
  8018a3:	f6 c1 03             	test   $0x3,%cl
  8018a6:	75 0a                	jne    8018b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018a8:	c1 e9 02             	shr    $0x2,%ecx
  8018ab:	89 c7                	mov    %eax,%edi
  8018ad:	fc                   	cld    
  8018ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b0:	eb 05                	jmp    8018b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b2:	89 c7                	mov    %eax,%edi
  8018b4:	fc                   	cld    
  8018b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b7:	5e                   	pop    %esi
  8018b8:	5f                   	pop    %edi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018be:	ff 75 10             	pushl  0x10(%ebp)
  8018c1:	ff 75 0c             	pushl  0xc(%ebp)
  8018c4:	ff 75 08             	pushl  0x8(%ebp)
  8018c7:	e8 87 ff ff ff       	call   801853 <memmove>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d9:	89 c6                	mov    %eax,%esi
  8018db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018de:	eb 1a                	jmp    8018fa <memcmp+0x2c>
		if (*s1 != *s2)
  8018e0:	0f b6 08             	movzbl (%eax),%ecx
  8018e3:	0f b6 1a             	movzbl (%edx),%ebx
  8018e6:	38 d9                	cmp    %bl,%cl
  8018e8:	74 0a                	je     8018f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ea:	0f b6 c1             	movzbl %cl,%eax
  8018ed:	0f b6 db             	movzbl %bl,%ebx
  8018f0:	29 d8                	sub    %ebx,%eax
  8018f2:	eb 0f                	jmp    801903 <memcmp+0x35>
		s1++, s2++;
  8018f4:	83 c0 01             	add    $0x1,%eax
  8018f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fa:	39 f0                	cmp    %esi,%eax
  8018fc:	75 e2                	jne    8018e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	53                   	push   %ebx
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80190e:	89 c1                	mov    %eax,%ecx
  801910:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801913:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801917:	eb 0a                	jmp    801923 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801919:	0f b6 10             	movzbl (%eax),%edx
  80191c:	39 da                	cmp    %ebx,%edx
  80191e:	74 07                	je     801927 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801920:	83 c0 01             	add    $0x1,%eax
  801923:	39 c8                	cmp    %ecx,%eax
  801925:	72 f2                	jb     801919 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801927:	5b                   	pop    %ebx
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	57                   	push   %edi
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801933:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801936:	eb 03                	jmp    80193b <strtol+0x11>
		s++;
  801938:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193b:	0f b6 01             	movzbl (%ecx),%eax
  80193e:	3c 20                	cmp    $0x20,%al
  801940:	74 f6                	je     801938 <strtol+0xe>
  801942:	3c 09                	cmp    $0x9,%al
  801944:	74 f2                	je     801938 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801946:	3c 2b                	cmp    $0x2b,%al
  801948:	75 0a                	jne    801954 <strtol+0x2a>
		s++;
  80194a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80194d:	bf 00 00 00 00       	mov    $0x0,%edi
  801952:	eb 11                	jmp    801965 <strtol+0x3b>
  801954:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801959:	3c 2d                	cmp    $0x2d,%al
  80195b:	75 08                	jne    801965 <strtol+0x3b>
		s++, neg = 1;
  80195d:	83 c1 01             	add    $0x1,%ecx
  801960:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801965:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80196b:	75 15                	jne    801982 <strtol+0x58>
  80196d:	80 39 30             	cmpb   $0x30,(%ecx)
  801970:	75 10                	jne    801982 <strtol+0x58>
  801972:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801976:	75 7c                	jne    8019f4 <strtol+0xca>
		s += 2, base = 16;
  801978:	83 c1 02             	add    $0x2,%ecx
  80197b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801980:	eb 16                	jmp    801998 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801982:	85 db                	test   %ebx,%ebx
  801984:	75 12                	jne    801998 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801986:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80198b:	80 39 30             	cmpb   $0x30,(%ecx)
  80198e:	75 08                	jne    801998 <strtol+0x6e>
		s++, base = 8;
  801990:	83 c1 01             	add    $0x1,%ecx
  801993:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801998:	b8 00 00 00 00       	mov    $0x0,%eax
  80199d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a0:	0f b6 11             	movzbl (%ecx),%edx
  8019a3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a6:	89 f3                	mov    %esi,%ebx
  8019a8:	80 fb 09             	cmp    $0x9,%bl
  8019ab:	77 08                	ja     8019b5 <strtol+0x8b>
			dig = *s - '0';
  8019ad:	0f be d2             	movsbl %dl,%edx
  8019b0:	83 ea 30             	sub    $0x30,%edx
  8019b3:	eb 22                	jmp    8019d7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019b5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b8:	89 f3                	mov    %esi,%ebx
  8019ba:	80 fb 19             	cmp    $0x19,%bl
  8019bd:	77 08                	ja     8019c7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019bf:	0f be d2             	movsbl %dl,%edx
  8019c2:	83 ea 57             	sub    $0x57,%edx
  8019c5:	eb 10                	jmp    8019d7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019c7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ca:	89 f3                	mov    %esi,%ebx
  8019cc:	80 fb 19             	cmp    $0x19,%bl
  8019cf:	77 16                	ja     8019e7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019d1:	0f be d2             	movsbl %dl,%edx
  8019d4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019da:	7d 0b                	jge    8019e7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019dc:	83 c1 01             	add    $0x1,%ecx
  8019df:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e5:	eb b9                	jmp    8019a0 <strtol+0x76>

	if (endptr)
  8019e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019eb:	74 0d                	je     8019fa <strtol+0xd0>
		*endptr = (char *) s;
  8019ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f0:	89 0e                	mov    %ecx,(%esi)
  8019f2:	eb 06                	jmp    8019fa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f4:	85 db                	test   %ebx,%ebx
  8019f6:	74 98                	je     801990 <strtol+0x66>
  8019f8:	eb 9e                	jmp    801998 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019fa:	89 c2                	mov    %eax,%edx
  8019fc:	f7 da                	neg    %edx
  8019fe:	85 ff                	test   %edi,%edi
  801a00:	0f 45 c2             	cmovne %edx,%eax
}
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5f                   	pop    %edi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a16:	85 c0                	test   %eax,%eax
  801a18:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1d:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	50                   	push   %eax
  801a24:	e8 f1 e8 ff ff       	call   80031a <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	75 10                	jne    801a40 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a30:	a1 04 40 80 00       	mov    0x804004,%eax
  801a35:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a38:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a3b:	8b 40 70             	mov    0x70(%eax),%eax
  801a3e:	eb 0a                	jmp    801a4a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a40:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a45:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a4a:	85 f6                	test   %esi,%esi
  801a4c:	74 02                	je     801a50 <ipc_recv+0x48>
  801a4e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a50:	85 db                	test   %ebx,%ebx
  801a52:	74 02                	je     801a56 <ipc_recv+0x4e>
  801a54:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a76:	0f 44 d8             	cmove  %eax,%ebx
  801a79:	eb 1c                	jmp    801a97 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7e:	74 12                	je     801a92 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a80:	50                   	push   %eax
  801a81:	68 20 22 80 00       	push   $0x802220
  801a86:	6a 40                	push   $0x40
  801a88:	68 32 22 80 00       	push   $0x802232
  801a8d:	e8 b3 f5 ff ff       	call   801045 <_panic>
        sys_yield();
  801a92:	e8 b4 e6 ff ff       	call   80014b <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a97:	ff 75 14             	pushl  0x14(%ebp)
  801a9a:	53                   	push   %ebx
  801a9b:	56                   	push   %esi
  801a9c:	57                   	push   %edi
  801a9d:	e8 55 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	75 d2                	jne    801a7b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801abc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801abf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac5:	8b 52 50             	mov    0x50(%edx),%edx
  801ac8:	39 ca                	cmp    %ecx,%edx
  801aca:	75 0d                	jne    801ad9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801acc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801acf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad4:	8b 40 48             	mov    0x48(%eax),%eax
  801ad7:	eb 0f                	jmp    801ae8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad9:	83 c0 01             	add    $0x1,%eax
  801adc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ae1:	75 d9                	jne    801abc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af0:	89 d0                	mov    %edx,%eax
  801af2:	c1 e8 16             	shr    $0x16,%eax
  801af5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b01:	f6 c1 01             	test   $0x1,%cl
  801b04:	74 1d                	je     801b23 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b06:	c1 ea 0c             	shr    $0xc,%edx
  801b09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b10:	f6 c2 01             	test   $0x1,%dl
  801b13:	74 0e                	je     801b23 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b15:	c1 ea 0c             	shr    $0xc,%edx
  801b18:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b1f:	ef 
  801b20:	0f b7 c0             	movzwl %ax,%eax
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    
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
