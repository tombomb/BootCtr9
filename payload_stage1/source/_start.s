.section .text.start
.align 4
.org 0x2B0
.global _start
_start:
    @ Disable IRQ
    mrs r0, cpsr
    orr r0, r0, #0x80
    msr cpsr_c, r0
	
    @ Enable caches
    mrc p15, 0, r0, c1, c0, 0  @ read control register
    orr r0, r0, #(1<<12)       @ - instruction cache enable
    orr r0, r0, #(1<<2)        @ - data cache enable
    orr r0, r0, #(1<<0)        @ - mpu enable
    mcr p15, 0, r0, c1, c0, 0  @ write control register

    @ Flush caches
    mov r0, #0
    mcr p15, 0, r0, c7, c5, 0  @ flush I-cache
    mcr p15, 0, r0, c7, c6, 0  @ flush D-cache
    mcr p15, 0, r0, c7, c10, 4 @ drain write buffer

    @ Change the stack pointer
    mov sp, #0x27000000

    @ Give read/write access to all the memory regions
    ldr r0, =0x33333333
    mcr p15, 0, r0, c5, c0, 2 @ write data access
    mcr p15, 0, r0, c5, c0, 3 @ write instruction access

    @ Set MPU permissions and cache settings
    ldr r0, =0xFFFF001D	@ ffff0000 32k
    ldr r1, =0x01FF801D	@ 01ff8000 32k
    ldr r2, =0x08000027	@ 08000000 1M
    ldr r3, =0x10000021	@ 10000000 128k
    ldr r4, =0x10100025	@ 10100000 512k
    ldr r5, =0x20000035	@ 20000000 128M
    ldr r6, =0x1FF00027	@ 1FF00000 1M
    ldr r7, =0x1800002D	@ 18000000 8M
    mcr p15, 0, r0, c6, c0, 0
    mcr p15, 0, r1, c6, c1, 0
    mcr p15, 0, r2, c6, c2, 0
    mcr p15, 0, r3, c6, c3, 0
    mcr p15, 0, r4, c6, c4, 0
    mcr p15, 0, r5, c6, c5, 0
    mcr p15, 0, r6, c6, c6, 0
    mcr p15, 0, r7, c6, c7, 0
    mov r0, #0x25
    mcr p15, 0, r0, c2, c0, 0  @ data cacheable
    mcr p15, 0, r0, c2, c0, 1  @ instruction cacheable
	mov r0, #0x5 @ Fixes payloads which don't like FCRAM as "data bufferable"
    mcr p15, 0, r0, c3, c0, 0  @ data bufferable

    bl main

.die:
    b .die