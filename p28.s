// ===============================================
// Estudiante y No de control: Perez Garcia Cesar Michael
// Descripcion: Programa en ensamblador ARM64 para convertir hexadecimal a decimal
// ===============================================

.data
prompt: .asciz "Ingrese un numero hexadecimal: "
result_msg: .asciz "El valor decimal es: %d\n"
error_msg: .asciz "Valor hexadecimal no valido\n"
format: .asciz "%s"

.bss
buffer: .skip 100

.text
.global main
.global hex_char_to_dec

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr x0, =prompt
    bl printf

    ldr x0, =format
    ldr x1, =buffer
    bl scanf

    ldr x20, =buffer
    mov w19, #0

bucle:
    ldrb w0, [x20], #1
    cmp w0, #0
    beq mostrar

    bl hex_char_to_dec
    cmp w0, #0
    blt error
    lsl w19, w19, #4
    add w19, w19, w0
    b bucle

mostrar:
    ldr x0, =result_msg
    mov w1, w19
    bl printf
    b fin

error:
    ldr x0, =error_msg
    bl printf

fin:
    ldp x29, x30, [sp], #16
    mov w0, #0
    ret

hex_char_to_dec:
    cmp w0, #'0'
    blt invalido
    cmp w0, #'9'
    ble es_digito

    cmp w0, #'A'
    blt invalido
    cmp w0, #'F'
    ble es_mayuscula

    cmp w0, #'a'
    blt invalido
    cmp w0, #'f'
    ble es_minuscula

invalido:
    mov w0, #-1
    ret

es_digito:
    sub w0, w0, #'0'
    ret

es_mayuscula:
    sub w0, w0, #'A'
    add w0, w0, #10
    ret

es_minuscula:
    sub w0, w0, #'a'
    add w0, w0, #10
    ret
