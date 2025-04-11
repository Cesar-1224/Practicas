// ===============================================
// Estudiante y No de control: Perez Garcia Cesar Michael
// Descripcion: Programa en ensamblador ARM64 para generar numeros aleatorios con semilla
// ===============================================

.data
prompt_seed: .asciz "Introduce una semilla: "
prompt_count: .asciz "Cuantos numeros aleatorios? "
output_msg: .asciz "Numero %d: %d\n"
format: .asciz "%d"

.bss
seed: .skip 4
count: .skip 4

.text
.global main
.global generar_aleatorio

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Leer semilla
    ldr x0, =prompt_seed
    bl printf
    ldr x0, =format
    ldr x1, =seed
    bl scanf
    ldr w19, seed

    // Leer cantidad
    ldr x0, =prompt_count
    bl printf
    ldr x0, =format
    ldr x1, =count
    bl scanf
    ldr w20, count

    mov w21, #1

bucle:
    cmp w21, w20
    bgt fin

    mov w0, w19
    bl generar_aleatorio
    mov w19, w0

    ldr x0, =output_msg
    mov w1, w21
    mov w2, w0
    bl printf

    add w21, w21, #1
    b bucle

fin:
    ldp x29, x30, [sp], #16
    mov w0, #0
    ret

// Generador lineal congruencial
generar_aleatorio:
    mov w1, #12345
    movz w2, 0x49E3
    movk w2, 0x4135, lsl #16
    mul w0, w0, w2
    add w0, w0, w1
    and w0, w0, 0x7FFFFFFF
    ret
