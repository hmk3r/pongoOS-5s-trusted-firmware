/*
 * pongoOS - https://checkra.in
 *
 * Copyright (C) 2019-2021 checkra1n team
 *
 * This file is part of pongoOS.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

 #include "el3-runtime/common.h"

.globl start
.align 4
start:
// branch from x27 will end up here
    mov x9, x8
// branch from x29 here
    adr x4, start
    mov x5, #0x800000000
    movk x5, #0x1800, lsl#16
    and x30, x30, 0x4
    orr x30, x30, x5
    cmp x4, x5
    b.eq start$l0
    add x6, x4, #0x200000

copyloop:
    ldr x3, [x4], #8
    str x3, [x5], #8
    cmp x4, x6
    b.ne copyloop

#ifdef AUTOBOOT
    ldr x3, [x6]
    mov x4, #0x800000000
    movk x4, #0x18e0, lsl#16
    mov x2, #0x7561
    movk x2, #0x6f74, lsl#16
    movk x2, #0x6f62, lsl#32
    movk x2, #0x746f, lsl#48
    cmp x3, x2
    b.ne nullsub
    ldr w2, [x6, #8]
    add w2, w2, #16
    and w2, w2, #(~15)

copyloop_2:
    cbz w2, copyloop_3
    sub w2, w2, #16
    ldp x10,x15, [x4], #16
    stp x10,x15, [x5], #16
    b copyloop_2
#endif
copyloop_3:
#ifdef AUTOBOOT
    str xzr, [x6]
#endif
    ret

start$l0:
    mov x1, x0
    mov x0, x9
    mov x29, xzr
    bl _set_exception_stack_core0
    bl _set_execution_stack_core0
    bl _trampoline_entry
    b .

.macro reserve_smc_stack_space
	sub sp, sp, #CTX_STACK_SIZE
.endm

.macro free_smc_stack_space
	sub sp, sp, #CTX_STACK_SIZE
.endm

.macro save_x30
	str	x30, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_LR]
.endm
/* Adapted from https://github.com/ARM-software/arm-trusted-firmware/blob/a0f3b552cfa45258099170c83f79619b2dbd7b9b/lib/el3_runtime/aarch64/context.S#L553
 *
 */
.macro save_gp_pmcr_pauth_regs
	stp	x0, x1, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X0]
	stp	x2, x3, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X2]
	stp	x4, x5, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X4]
	stp	x6, x7, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X6]
	stp	x8, x9, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X8]
	stp	x10, x11, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X10]
	stp	x12, x13, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X12]
	stp	x14, x15, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X14]
	stp	x16, x17, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X16]
	stp	x18, x19, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X18]
	stp	x20, x21, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X20]
	stp	x22, x23, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X22]
	stp	x24, x25, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X24]
	stp	x26, x27, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X26]
	stp	x28, x29, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X28]
	// mrs	x18, sp_el0
	str	x18, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_SP_EL0]
	// mrs	x9, pmcr_el0
	str	x9, [sp, #CTX_EL3STATE_OFFSET + CTX_PMCR_EL0]
	/* Disable cycle counter when event counting is prohibited */
	// sorr	x9, x9, #PMCR_EL0_DP_BIT
	// msr	pmcr_el0, x9
	// isb
.endm /* save_gp_pmcr_pauth_regs */


_restore_gp_pmcr_pauth_regs:
	ldr	x0, [sp, #CTX_EL3STATE_OFFSET + CTX_PMCR_EL0]
	// msr	pmcr_el0, x0
	ldp	x0, x1, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X0]
	ldp	x2, x3, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X2]
	ldp	x4, x5, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X4]
	ldp	x6, x7, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X6]
	ldp	x8, x9, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X8]
	ldp	x10, x11, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X10]
	ldp	x12, x13, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X12]
	ldp	x14, x15, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X14]
	ldp	x16, x17, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X16]
	ldp	x18, x19, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X18]
	ldp	x20, x21, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X20]
	ldp	x22, x23, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X22]
	ldp	x24, x25, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X24]
	ldp	x26, x27, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X26]
	ldr	x28, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_SP_EL0]
	// msr	sp_el0, x28
	ldp	x28, x29, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X28]
	ret

.macro enable_serror_at_el3
	mrs     x8, scr_el3
	orr     x8, x8, #SCR_EA_BIT
	msr     scr_el3, x8
.endm

_prepare_el3_entry:
	save_gp_pmcr_pauth_regs
	enable_serror_at_el3
	/*
	 * Set the PSTATE bits not described in the Aarch64.TakeException
	 * pseudocode to their default values.
	 */
	// set_unset_pstate_bits // Unknown if supported
	ret

/* Adapted from https://github.com/ARM-software/arm-trusted-firmware/blob/a0f3b552cfa45258099170c83f79619b2dbd7b9b/bl31/aarch64/runtime_exceptions.S#L123
 *
 */
.macro	handle_sync_exception
	mrs	x30, esr_el3
	ubfx	x30, x30, #ESR_EC_SHIFT, #ESR_EC_LENGTH

	/* Handle SMC exceptions separately from other synchronous exceptions */
	cmp	x30, #EC_AARCH32_SMC
	b.eq	smc_handler32

	cmp	x30, #EC_AARCH64_SMC
	b.eq	sync_handler64 // default case

	cmp	x30, #EC_AARCH64_SYS
	b.eq	sync_handler64

	/* Synchronous exceptions other than the above are assumed to be EA */
	ldr	x30, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_LR]
	b	smc_prohibited // handle_lower_el_sync_ea

.endm /* handle_sync_exception */
	
.macro exception_return
	eret
.endm

.globl _setup_el1
_setup_el1:
    stp x29, x30, [sp, #-0x10]!
    mov x20, x1
    mov x21, x2
    mrs x16, currentel
    cmp x16, #0x4
    b.eq el1_entry
    cmp x16, #0xc
    b.ne .

el3_entry:

    adr x16, _exception_vector_el3
    msr vbar_el3, x16
    mov x16, #0x430
    msr scr_el3, x16
    mov x16, #4
    msr spsr_el3, x16
    adr x16, el1_entry
    msr elr_el3, x0
    eret

el1_entry:
    blr x0
    b .

.globl _set_exception_stack_core0
_set_exception_stack_core0:
    msr spsel, #1
    adrp x8, _exception_stack@PAGE
    add x8, x8, _exception_stack@PAGEOFF
    add x8, x8, #0x4000
    and x8, x8, #~0xf
    mov sp, x8
    msr spsel, #0
    ret

.globl _set_execution_stack_core0
_set_execution_stack_core0:
    msr spsel, #0
    adrp x8, _sched_stack@PAGE
    add x8, x8, _sched_stack@PAGEOFF
    add x8, x8, #0x4000
    and x8, x8, #~0xf
    mov sp, x8
    ret

.globl _smemcpy128
_smemcpy128:
    cbz w2, nullsub
    sub w2, w2, #1
    ldp x3,x4, [x1], #16
    stp x3,x4, [x0], #16
    b _smemcpy128

.globl _smemset
_smemset:
    and w1, w1, #0xFF
    mov x3, x0
memset$continue:
    cbz x2, nullsub
    strb w1, [x0], #1
    sub x2, x2, #1
    b memset$continue

nullsub:
    ret

.align 12
.globl _exception_vector_el3
/* Current EL with SP0 */
_exception_vector_el3:
    // Synchronous
    eret
.balign 128
    // IRQ/vIRQ
    eret
.balign 128
    // FIQ/vFIQ
    eret
.balign 128
    // SError/vSError
    eret

/* Current EL with SPx */ 
.balign 128
    // Synchronous
    eret
.balign 128
    // IRQ/vIRQ
    eret
.balign 128
    // FIQ/vFIQ
    eret
.balign 128
    // SError/vSError
    eret

/* Lower EL using AArch64 */
.balign 128
    // Synchronous
	reserve_smc_stack_space
	// save_x30
	// handle_sync_exception
	save_gp_pmcr_pauth_regs

	ldr x1, =0xdeadbeef
	
	bl _el3_fibonacci_demo

	bl _restore_gp_pmcr_pauth_regs
	free_smc_stack_space

	exception_return

.balign 128
    // IRQ/vIRQ
    eret
.balign 128
    // FIQ/vFIQ
    eret
.balign 128
    // SError/vSError
    eret

/* Lower EL using AArch32 */
.balign 128
    // Synchronous
	save_x30
    handle_sync_exception

.balign 128
    // IRQ/vIRQ
    eret
.balign 128
    // FIQ/vFIQ
    eret
.balign 128
    // SError/vSError
    eret

// complete
_el3_exit:
	/* ----------------------------------------------------------
	 * Save the current SP_EL0 i.e. the EL3 runtime stack which
	 * will be used for handling the next SMC.
	 * Then switch to SP_EL3.
	 * ----------------------------------------------------------
	 */
	mov	x17, sp
	msr	spsel, #MODE_SP_ELX
	str	x17, [sp, #CTX_EL3STATE_OFFSET + CTX_RUNTIME_SP]

	dsb	sy

	/* ---------save_x30-------------------------------------------------
	 * Restore SPSR_EL3, ELR_EL3 and SCR_EL3 prior to ERET
	 * ----------------------------------------------------------
	 */
	ldr	x18, [sp, #CTX_EL3STATE_OFFSET + CTX_SCR_EL3]
	ldp	x16, x17, [sp, #CTX_EL3STATE_OFFSET + CTX_SPSR_EL3]
	msr	scr_el3, x18
	msr	spsr_el3, x16
	msr	elr_el3, x17

	/* ----------------------------------------------------------
	 * Restore general purpose (including x30), PMCR_EL0 and
	 * ARMv8.3-PAuth registers.
	 * Exit EL3 via ERET to a lower exception level.
 	 * ----------------------------------------------------------
 	 */
	bl _restore_gp_pmcr_pauth_regs
	ldr	x30, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_LR]

	free_smc_stack_space
	exception_return


/* dirty
    :lo12:rt_svc_descs_indices
    handle_sysreg_trap - unsupported
    elx_panic - replaced with smc_prohibited
 */
_sync_exception_handler:
smc_handler32:
	/* Check whether aarch32 issued an SMC64 */
	tbnz	x0, #FUNCID_CC_SHIFT, smc_prohibited

sync_handler64:
	/* NOTE: The code below must preserve x0-x4 */

	/*
	 * Save general purpose and ARMv8.3-PAuth registers (if enabled).
	 * Also save PMCR_EL0 and  set the PSTATE to a known state.
	 */
	bl	_prepare_el3_entry

	/*
	 * Populate the parameters for the SMC handler.
	 * We already have x0-x4 in place. x5 will point to a cookie (not used
	 * now). x6 will point to the context structure (SP_EL3) and x7 will
	 * contain flags we need to pass to the handler.
	 */
	mov	x5, xzr
	mov	x6, sp

	/*
	 * Restore the saved C runtime stack value which will become the new
	 * SP_EL0 i.e. EL3 runtime stack. It was saved in the 'cpu_context'
	 * structure prior to the last ERET from EL3.
	 */
	ldr	x12, [x6, #CTX_EL3STATE_OFFSET + CTX_RUNTIME_SP]

	/* Switch to SP_EL0 */
	msr	spsel, #MODE_SP_EL0

	/*
	 * Save the SPSR_EL3 and ELR_EL3 in case there is a world
	 * switch during SMC handling.
	 * TODO: Revisit if all system registers can be saved later.
	 */
	mrs	x16, spsr_el3
	mrs	x17, elr_el3
	stp	x16, x17, [x6, #CTX_EL3STATE_OFFSET + CTX_SPSR_EL3]

	/* Load SCR_EL3 */
	mrs	x18, scr_el3

	/* check for system register traps */
	mrs	x16, esr_el3
	ubfx	x17, x16, #ESR_EC_SHIFT, #ESR_EC_LENGTH
	cmp	x17, #EC_AARCH64_SYS
	b.eq	sysreg_handler64

	/* Clear flag register */
	mov	x7, xzr

	/* Copy SCR_EL3.NS bit to the flag to indicate caller's security */
	bfi	x7, x18, #0, #1

	mov	sp, x12

	/*
	 * Call the Secure Monitor Call handler and then drop directly into
	 * el3_exit() which will program any remaining architectural state
	 * prior to issuing the ERET to the desired lower EL.
	 */
	
	adr x15, _el3_fibonacci_demo
	blr	x15

	b	_el3_exit

sysreg_handler64:

	/* advance the PC to continue after the instruction */
	ldr	x1, [x19, #CTX_EL3STATE_OFFSET + CTX_ELR_EL3]
	add	x1, x1, #4
	str	x1, [x19, #CTX_EL3STATE_OFFSET + CTX_ELR_EL3]
1:
	b	_el3_exit

smc_unknown:
	/*
	 * Unknown SMC call. Populate return value with SMC_UNK and call
	 * el3_exit() which will restore the remaining architectural state
	 * i.e., SYS, GP and PAuth registers(if any) prior to issuing the ERET
	 * to the desired lower EL.
	 */
	mov	x0, #SMC_UNK
	str	x0, [x6, #CTX_GPREGS_OFFSET + CTX_GPREG_X0]
	b	_el3_exit

smc_prohibited:
	// restore_ptw_el1_sys_regs
	ldp	x28, x29, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X28]
	ldr	x30, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_LR]
	mov	x0, #SMC_UNK
	exception_return

_el3_fibonacci_demo:
	// work variables
	mov x22, #0 // n-2
	mov x23, #1 // n-1
	// x24 - n

	// parameter supplied by caller
	ldr x25, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X1]

	// edge cases
	mov x24, #1 // F(1)
	cmp x25, #1
	beq fibonacci_ret

	mov x24, #0 // F(0)
	cmp x25, #0
	beq fibonacci_ret

	sub x25, x25, #1 // decrease counter, because of default cases we need n-1 computations to compute n

fibonacci_loop:
	add x24, x23, x22
	mov x22, x23
	mov x23, x24

	// decrease counter and branch
	sub x25, x25, #1
	cmp x25, #0
	bne fibonacci_loop

fibonacci_ret:
	str x24, [sp, #CTX_GPREGS_OFFSET + CTX_GPREG_X2]
	ret

