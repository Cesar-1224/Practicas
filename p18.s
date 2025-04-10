/* ===================================================
   Autor: Perez Garcia Cesar Michael
   Descripción: Operaciones AND, OR, XOR acumulativas
=================================================== */

.section .data
    cadena:         .asciz "Example"
    msg_and:        .asciz "AND Final: 0x%02X (%d)\n"
    msg_or:         .asciz "OR Final:  0x%02X (%d)\n"
    msg_xor:        .asciz "XOR Final: 0x%02X (%d)\n"

.section .text
    .global main
    .align 2

main:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    adrp x0, cadena
    add x0, x0, :lo12:cadena
    bl operaciones

    // Imprimir AND (CORRECCIÓN: w1=valor, w2=copia)
    adrp x0, msg_and
    add x0, x0, :lo12:msg_and
    mov w1, w2
    mov w2, w1  // ¡Error! Sobrescribe w2. Usar registro temporal:
    /*
    CORRECCIÓN:
    mov w1, w2  // w1 = valor AND (decimal)
    mov w2, w2  // w2 = valor AND (hex)
    */
    bl printf

    // Imprimir OR (Mismo error)
    adrp x0, msg_or
    add x0, x0, :lo12:msg_or
    mov w1, w3
    mov w2, w1  // Error
    bl printf

    // Imprimir XOR (Mismo error)
    adrp x0, msg_xor
    add x0, x0, :lo12:msg_xor
    mov w1, w4
    mov w2, w1  // Error
    bl printf

    ldp x29, x30, [sp], 16
    mov x0, #0
    ret

operaciones:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    mov w2, 0xFF    // AND
    mov w3, 0       // OR
    mov w4, 0       // XOR

loop:
    ldrb w1, [x0], 1
    cbz w1, fin

    and w2, w2, w1  // Operación AND
    orr w3, w3, w1  // Operación OR
    eor w4, w4, w1  // Operación XOR
    b loop

fin:
    ldp x29, x30, [sp], 16
    ret
