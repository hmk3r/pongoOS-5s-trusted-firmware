/*
 * Adapted from:
 * https://github.com/ARM-software/arm-trusted-firmware/blob/master/include/lib/el3_runtime/aarch64/context.h
 * https://github.com/ARM-software/arm-trusted-firmware/blob/master/include/arch/aarch64/arch.h
 * https://github.com/ARM-software/arm-trusted-firmware/blob/master/include/lib/smccc.h
 * https://github.com/ARM-software/arm-trusted-firmware/blob/master/include/common/runtime_svc.h
 *
 */

#ifndef EL3_COMMON_H
#define EL3_COMMON_H

#if defined(__ASSEMBLER__)
# define   U(_x)	(_x)
# define  UL(_x)	(_x)
# define ULL(_x)	(_x)
# define   L(_x)	(_x)
# define  LL(_x)	(_x)
#else
# define  U_(_x)	(_x##U)
# define   U(_x)	U_(_x)
# define  UL(_x)	(_x##UL)
# define ULL(_x)	(_x##ULL)
# define   L(_x)	(_x##L)
# define  LL(_x)	(_x##LL)

#endif

/*******************************************************************************
 * Constants that allow assembler code to access members of and the 'gp_regs'
 * structure at their correct offsets.
 ******************************************************************************/
#define CTX_GPREGS_OFFSET U(0x0)
#define CTX_GPREG_X0 U(0x0)
#define CTX_GPREG_X1 U(0x8)
#define CTX_GPREG_X2 U(0x10)
#define CTX_GPREG_X3 U(0x18)
#define CTX_GPREG_X4 U(0x20)
#define CTX_GPREG_X5 U(0x28)
#define CTX_GPREG_X6 U(0x30)
#define CTX_GPREG_X7 U(0x38)
#define CTX_GPREG_X8 U(0x40)
#define CTX_GPREG_X9 U(0x48)
#define CTX_GPREG_X10 U(0x50)
#define CTX_GPREG_X11 U(0x58)
#define CTX_GPREG_X12 U(0x60)
#define CTX_GPREG_X13 U(0x68)
#define CTX_GPREG_X14 U(0x70)
#define CTX_GPREG_X15 U(0x78)
#define CTX_GPREG_X16 U(0x80)
#define CTX_GPREG_X17 U(0x88)
#define CTX_GPREG_X18 U(0x90)
#define CTX_GPREG_X19 U(0x98)
#define CTX_GPREG_X20 U(0xa0)
#define CTX_GPREG_X21 U(0xa8)
#define CTX_GPREG_X22 U(0xb0)
#define CTX_GPREG_X23 U(0xb8)
#define CTX_GPREG_X24 U(0xc0)
#define CTX_GPREG_X25 U(0xc8)
#define CTX_GPREG_X26 U(0xd0)
#define CTX_GPREG_X27 U(0xd8)
#define CTX_GPREG_X28 U(0xe0)
#define CTX_GPREG_X29 U(0xe8)
#define CTX_GPREG_LR U(0xf0)
#define CTX_GPREG_SP_EL0 U(0xf8)
#define CTX_GPREGS_END U(0x100)

/*******************************************************************************
 * Constants that allow assembler code to access members of and the 'el3_state'
 * structure at their correct offsets. Note that some of the registers are only
 * 32-bits wide but are stored as 64-bit values for convenience
 ******************************************************************************/
#define CTX_EL3STATE_OFFSET (CTX_GPREGS_OFFSET + CTX_GPREGS_END)
#define CTX_SCR_EL3 U(0x0)
#define CTX_ESR_EL3 U(0x8)
#define CTX_RUNTIME_SP U(0x10)
#define CTX_SPSR_EL3 U(0x18)
#define CTX_ELR_EL3 U(0x20)
#define CTX_PMCR_EL0 U(0x28)
#define CTX_IS_IN_EL3 U(0x30)
#define CTX_CPTR_EL3 U(0x38)
#define CTX_ZCR_EL3 U(0x40)
#define CTX_EL3STATE_END U(0x50) /* Align to the next 16 byte boundary */

#define CTX_STACK_SIZE (CTX_EL3STATE_OFFSET + CTX_EL3STATE_END) // dirty hakz

/* Exception Syndrome register bits and bobs */
#define ESR_EC_SHIFT U(26)
#define ESR_EC_MASK U(0x3f)
#define ESR_EC_LENGTH U(6)
#define ESR_ISS_SHIFT U(0)
#define ESR_ISS_LENGTH U(25)
#define EC_UNKNOWN U(0x0)
#define EC_WFE_WFI U(0x1)
#define EC_AARCH32_CP15_MRC_MCR U(0x3)
#define EC_AARCH32_CP15_MRRC_MCRR U(0x4)
#define EC_AARCH32_CP14_MRC_MCR U(0x5)
#define EC_AARCH32_CP14_LDC_STC U(0x6)
#define EC_FP_SIMD U(0x7)
#define EC_AARCH32_CP10_MRC U(0x8)
#define EC_AARCH32_CP14_MRRC_MCRR U(0xc)
#define EC_ILLEGAL U(0xe)
#define EC_AARCH32_SVC U(0x11)
#define EC_AARCH32_HVC U(0x12)
#define EC_AARCH32_SMC U(0x13)
#define EC_AARCH64_SVC U(0x15)
#define EC_AARCH64_HVC U(0x16)
#define EC_AARCH64_SMC U(0x17)
#define EC_AARCH64_SYS U(0x18)
#define EC_IABORT_LOWER_EL U(0x20)
#define EC_IABORT_CUR_EL U(0x21)
#define EC_PC_ALIGN U(0x22)
#define EC_DABORT_LOWER_EL U(0x24)
#define EC_DABORT_CUR_EL U(0x25)
#define EC_SP_ALIGN U(0x26)
#define EC_AARCH32_FP U(0x28)
#define EC_AARCH64_FP U(0x2c)
#define EC_SERROR U(0x2f)
#define EC_BRK U(0x3c)

/* SCR definitions */
#define SCR_RES1_BITS ((U(1) << 4) | (U(1) << 5))
#define SCR_NSE_SHIFT U(62)
#define SCR_NSE_BIT (ULL(1) << SCR_NSE_SHIFT)
#define SCR_GPF_BIT (UL(1) << 48)
#define SCR_TWEDEL_SHIFT U(30)
#define SCR_TWEDEL_MASK ULL(0xf)
#define SCR_PIEN_BIT (UL(1) << 45)
#define SCR_TCR2EN_BIT (UL(1) << 43)
#define SCR_TRNDR_BIT (UL(1) << 40)
#define SCR_GCSEn_BIT (UL(1) << 39)
#define SCR_HXEn_BIT (UL(1) << 38)
#define SCR_ENTP2_SHIFT U(41)
#define SCR_ENTP2_BIT (UL(1) << SCR_ENTP2_SHIFT)
#define SCR_AMVOFFEN_SHIFT U(35)
#define SCR_AMVOFFEN_BIT (UL(1) << SCR_AMVOFFEN_SHIFT)
#define SCR_TWEDEn_BIT (UL(1) << 29)
#define SCR_ECVEN_BIT (UL(1) << 28)
#define SCR_FGTEN_BIT (UL(1) << 27)
#define SCR_ATA_BIT (UL(1) << 26)
#define SCR_EnSCXT_BIT (UL(1) << 25)
#define SCR_FIEN_BIT (UL(1) << 21)
#define SCR_EEL2_BIT (UL(1) << 18)
#define SCR_API_BIT (UL(1) << 17)
#define SCR_APK_BIT (UL(1) << 16)
#define SCR_TERR_BIT (UL(1) << 15)
#define SCR_TWE_BIT (UL(1) << 13)
#define SCR_TWI_BIT (UL(1) << 12)
#define SCR_ST_BIT (UL(1) << 11)
#define SCR_RW_BIT (UL(1) << 10)
#define SCR_SIF_BIT (UL(1) << 9)
#define SCR_HCE_BIT (UL(1) << 8)
#define SCR_SMD_BIT (UL(1) << 7)
#define SCR_EA_BIT (UL(1) << 3)
#define SCR_FIQ_BIT (UL(1) << 2)
#define SCR_IRQ_BIT (UL(1) << 1)
#define SCR_NS_BIT (UL(1) << 0)
#define SCR_VALID_BIT_MASK U(0x24000002F8F)
#define SCR_RESET_VAL SCR_RES1_BITS

/* PMCR_EL0 definitions */
#define PMCR_EL0_RESET_VAL	U(0x0)
#define PMCR_EL0_N_SHIFT	U(11)
#define PMCR_EL0_N_MASK		U(0x1f)
#define PMCR_EL0_N_BITS		(PMCR_EL0_N_MASK << PMCR_EL0_N_SHIFT)
#define PMCR_EL0_LP_BIT		(U(1) << 7)
#define PMCR_EL0_LC_BIT		(U(1) << 6)
#define PMCR_EL0_DP_BIT		(U(1) << 5)
#define PMCR_EL0_X_BIT		(U(1) << 4)
#define PMCR_EL0_D_BIT		(U(1) << 3)
#define PMCR_EL0_C_BIT		(U(1) << 2)
#define PMCR_EL0_P_BIT		(U(1) << 1)
#define PMCR_EL0_E_BIT		(U(1) << 0)

/*******************************************************************************
 * Bit definitions inside the function id as per the SMC calling convention
 ******************************************************************************/
#define FUNCID_TYPE_SHIFT U(31)
#define FUNCID_TYPE_MASK U(0x1)
#define FUNCID_TYPE_WIDTH U(1)

#define FUNCID_CC_SHIFT U(30)
#define FUNCID_CC_MASK U(0x1)
#define FUNCID_CC_WIDTH U(1)

#define FUNCID_OEN_SHIFT U(24)
#define FUNCID_OEN_MASK U(0x3f)
#define FUNCID_OEN_WIDTH U(6)

#define FUNCID_FC_RESERVED_SHIFT U(17)
#define FUNCID_FC_RESERVED_MASK U(0x7f)
#define FUNCID_FC_RESERVED_WIDTH U(7)

#define FUNCID_SVE_HINT_SHIFT U(16)
#define FUNCID_SVE_HINT_MASK U(1)
#define FUNCID_SVE_HINT_WIDTH U(1)

#define FUNCID_NUM_SHIFT U(0)
#define FUNCID_NUM_MASK U(0xffff)
#define FUNCID_NUM_WIDTH U(16)

#define FUNCID_MASK U(0xffffffff)

#define GET_SMC_NUM(id) (((id) >> FUNCID_NUM_SHIFT) & FUNCID_NUM_MASK)
#define GET_SMC_TYPE(id) (((id) >> FUNCID_TYPE_SHIFT) & FUNCID_TYPE_MASK)
#define GET_SMC_CC(id) (((id) >> FUNCID_CC_SHIFT) & FUNCID_CC_MASK)
#define GET_SMC_OEN(id) (((id) >> FUNCID_OEN_SHIFT) & FUNCID_OEN_MASK)

/* Flags and error codes */
#define SMC_64 U(1)
#define SMC_32 U(0)

#define SMC_TYPE_FAST UL(1)
#define SMC_TYPE_YIELD UL(0)

#define SMC_OK ULL(0)
#define SMC_UNK -1
#define SMC_PREEMPTED -2 /* Not defined by the SMCCC */

#define MODE_SP_SHIFT U(0x0)
#define MODE_SP_MASK U(0x1)
#define MODE_SP_EL0 U(0x0)
#define MODE_SP_ELX U(0x1)

#define MODE_RW_SHIFT U(0x4)
#define MODE_RW_MASK U(0x1)
#define MODE_RW_64 U(0x0)
#define MODE_RW_32 U(0x1)

#define MODE_EL_SHIFT U(0x2)
#define MODE_EL_MASK U(0x3)
#define MODE_EL_WIDTH U(0x2)
#define MODE_EL3 U(0x3)
#define MODE_EL2 U(0x2)
#define MODE_EL1 U(0x1)
#define MODE_EL0 U(0x0)

#define MODE32_SHIFT U(0)
#define MODE32_MASK U(0xf)
#define MODE32_usr U(0x0)
#define MODE32_fiq U(0x1)
#define MODE32_irq U(0x2)
#define MODE32_svc U(0x3)
#define MODE32_mon U(0x6)
#define MODE32_abt U(0x7)
#define MODE32_hyp U(0xa)
#define MODE32_und U(0xb)
#define MODE32_sys U(0xf)

#define GET_RW(mode) (((mode) >> MODE_RW_SHIFT) & MODE_RW_MASK)
#define GET_EL(mode) (((mode) >> MODE_EL_SHIFT) & MODE_EL_MASK)
#define GET_SP(mode) (((mode) >> MODE_SP_SHIFT) & MODE_SP_MASK)
#define GET_M32(mode) (((mode) >> MODE32_SHIFT) & MODE32_MASK)

#define RT_SVC_SIZE_LOG2 U(5)
#define RT_SVC_DESC_INIT U(16)
#define RT_SVC_DESC_HANDLE U(24)

#define __RT_SVC_DESCS_START__ Load$$__RT_SVC_DESCS__$$Base
#define __RT_SVC_DESCS_END__ Load$$__RT_SVC_DESCS__$$Limit

#endif // EL3_COMMON_H