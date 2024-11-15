# SPDX-FileCopyrightText: 2024 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

.global main
.func main

main: /* This is main */
    mov r0, #2 /* Put a 2 into register r0 */
    bx lr /* Return from main */
