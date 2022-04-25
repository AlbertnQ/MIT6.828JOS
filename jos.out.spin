+ ld obj/kern/kernel
+ mk obj/kern/kernel.img
6828 decimal is 015254 octal!
Physical memory: 131072K available, base = 640K, extended = 130432K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2 4
[00000000] new env 00001000
[00000000] new env 00001001
FS is running
FS can do I/O
Device 1 presence: 1
I am the parent.  Forking the child...
[00001001] new env 00001002
I am the parent.  Running the child...
I am the child.  Spinning...
block cache is good
superblock is good
bitmap is good
alloc_block is good
file_open is good
file_get_block is good
file_flush is good
file_truncate is good
file rewrite is good
I am the parent.  Killing the child...
[00001001] free env 00001002
[00001001] free env 00001001
No runnable environments in the system!
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
qemu: terminating on signal 15 from pid 65651
