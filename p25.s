/*
    Autor: Perez Garcia Cesar Michael
    Descripción: Solicita dos números al usuario, los multiplica y muestra el resultado.
*/

.section .data
prompt1:    .asciz "Ingrese el primer número: "
prompt2:    .asciz "Ingrese el segundo número: "
resultado:  .asciz "Resultado de la multiplicación: "
buffer:     .skip 32         // Espacio para entrada
resbuf:     .skip 32         // Espacio para salida

.section .text
.global _start

_start:
    // Mostrar mensaje 1
    ldr x0, =prompt1
    bl print_str

    // Leer primer número
    mov x0, #0          // stdin
    ldr x1, =buffer
    mov x2, #32
    mov x8, #63         // syscall read
    svc 0

    // Convertir primer número
    ldr x1, =buffer
    bl str_to_int
    mov x9, x0          // Guardar primer número

    // Mostrar mensaje 2
    ldr x0, =prompt2
    bl print_str

    // Leer segundo número
    mov x0, #0
    ldr x1, =buffer
    mov x2, #32
    mov x8, #63
    svc 0

    // Convertir segundo número
    ldr x1, =buffer
    bl str_to_int

    // Multiplicación
    mul x0, x9, x0

    // Convertir resultado a string
    mov x1, x0          // número en x1
    ldr x2, =resbuf
    bl int_to_str

    // Imprimir resultado
    ldr x0, =resultado
    bl print_str
    ldr x0, =resbuf
    bl print_str

    // Salir
    mov x8, #93
    mov x0, #0
    svc 0

//------------------------------------------
// str_to_int: Convierte cadena a entero
// Entrada: x1 = puntero a cadena
// Salida: x0 = número
//------------------------------------------
str_to_int:
    mov x0, #0          // acumulador
    mov x2, #10         // base decimal
1:
    ldrb w3, [x1], #1
    cmp w3, #10         // \n
    beq 2f
    sub w3, w3, #'0'
    mul x0, x0, x2
    add x0, x0, x3
    b 1b
2:
    ret

//------------------------------------------
// int_to_str: Convierte entero a string
// Entrada: x1 = número, x2 = buffer
//------------------------------------------
int_to_str:
    mov x3, #10
    mov x4, x2
1:
    udiv x5, x1, x3
    msub x6, x5, x3, x1
    add x6, x6, #'0'
    strb w6, [x4], #1
    mov x1, x5
    cbnz x1, 1b

    // invertir cadena
    sub x7, x4, x2
    sub x7, x7, #1
    mov x8, #0
2:
    cmp x8, x7
    bge 3f
    ldrb w9, [x2, x8]
    ldrb w10, [x2, x7]
    strb w10, [x2, x8]
    strb w9, [x2, x7]
    add x8, x8, #1
    sub x7, x7, #1
    b 2b
3:
    ret

//------------------------------------------
// print_str: Imprime cadena NULL-terminada
// Entrada: x0 = puntero
//------------------------------------------
print_str:
    mov x1, x0
    mov x2, #0
count_len:
    ldrb w3, [x1, x2]
    cmp w3, #0
    beq print_now
    add x2, x2, #1
    b count_len

print_now:
    mov x8, #64         // write
    mov x1, x0
    mov x0, #1          // stdout
    svc 0
    ret
