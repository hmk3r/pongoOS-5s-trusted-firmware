#include "pongo.h"

void el3_smc_call() {
    printf("Making SMC call\n");
    __asm__ ("smc #0");
    printf("Didn't crash\n");
}

void el3_fib(const char* cmd, char* args) {
    if (! *args) {
        iprintf("el3_fib usage: el3_fib [N]\n");
        return;
    }

    printf("Calling EL3 fibonacci compute\n");
    
    uint64_t n = strtoull(args, NULL, 10);
    uint64_t res = 0;
    uint64_t reg_check = 0;
    
    asm volatile ("mov x1, %0" ::"r"(n) :);
    asm volatile ("mov x2, #69");

    __asm__ ("smc #0");

    asm volatile ("mov %0, x2" : "=r"(res) ::);
    asm volatile ("mov %0, x1" : "=r"(reg_check) ::);

    printf("The %lluth fibonacci number is %llu\n", n, res);
    printf("Reg x1 check Expected: 0x%016llX, Returned: 0x%016llX\n", n, reg_check);
}

void el_info() {
    const uint64_t sanity_check_val = 0x9192939495969798;

    const uint64_t* elr_el3_ptr = (uint64_t*) 0x803000000;
    const uint64_t* current_el_ptr = (uint64_t*) 0x803000008;
    const uint64_t* sanity_check_ptr = (uint64_t*) 0x803000010;

    printf("Making SMC call\n");
    __asm__ ("smc #0");

    uint64_t sanity_check_mem = *sanity_check_ptr;
    uint64_t current_el = *current_el_ptr;

    printf("During the SMC call, the following values were observed:\n");
    printf("\tELR_EL3 Register: %016llX\n", *elr_el3_ptr);
    printf("\tCurrentEL Register: %016llX\n", current_el);
    // EL is stored in bits [3:2]
    printf("\tEL = %llu\n", current_el >> 2);
    printf("\tSanity check value: %016llX, matches? - %s\n", sanity_check_mem, sanity_check_mem == sanity_check_val ? "true" : "false");
}

void el3_commands_register() {
    command_register("el3_smc_call", "Do an SMC call", el3_smc_call);
    command_register("el3_fib", "Compute the Nth fibonacci number", el3_fib);
    // command_register("el_info", "Checks the current EL and attempts to retrieve ELR_EL3", el_info);
}