// ===============================================
// Estudiante y No de control: Perez Garcia Cesar Michael
// Descripcion: Programa en ensamblador ARM64 para dividir 2 numeros
// ===============================================

.data
prompt1:    .asciz "Ingrese el primer numero: "
prompt2:    .asciz "Ingrese el segundo numero: "
result_msg: .asciz "El resultado de la division es: %d\n"
error_msg:  .asciz "Error: No se puede dividir por cero\n"
format:     .asciz "%d"

.bss
buffer1:    .skip 4
buffer2:    .skip 4

.text
.global main

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Primer número
    ldr x0, =prompt1
    bl printf
    ldr x0, =format
    ldr x1, =buffer1
    bl scanf
    ldr w19, buffer1

    // Segundo número
    ldr x0, =prompt2
    bl printf
    ldr x0, =format
    ldr x1, =buffer2
    bl scanf
    ldr w20, buffer2

    // Validar división por cero
    cmp w20, #0
    beq division_por_cero

    sdiv w21, w19, w20
    ldr x0, =result_msg
    mov w1, w21
    bl printf
    b fin

division_por_cero:
    ldr x0, =error_msg
    bl printf

fin:
    ldp x29, x30, [sp], #16
    mov w0, #0
    ret
