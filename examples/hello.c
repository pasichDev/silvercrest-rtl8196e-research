/* SPDX-License-Identifier: MIT
 * Minimal userspace ABI smoke test. No gateway product code.
 */
#include <stdio.h>

int main(void)
{
    puts("hello from big-endian MIPS userspace");
    return 0;
}
