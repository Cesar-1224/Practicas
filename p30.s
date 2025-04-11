/*
=========================================
Programa: Convertir binario a decimal
Autor: Perez Garcia Cesar Michael
Descripción: Convierte una cadena binaria a decimal (ARM64, sin libc)
Codigo en ensamblador
=========================================
*/

        .section .data
binario:      .asciz "11101" // binario de ejemplo (11101 = 29)
mensaje:      .asciz "El decimal es: "
buffer:       .space 32      // Espacio para la salida en decimal

        .section .text
        .global _start

_start:
        // Mostrar mensaje
        ldr x0, =mensaje
        bl print_str

        // Convertir binario a decimal
        ldr x1, =binario  // x1 = puntero a cadena binaria
        mov x2, #0        // x2 = acumulador decimal

loop:
        ldrb w3, [x1], #1     // Leer siguiente carácter
        cbz w3, convertir     // Si es nulo, salta a conversión
        sub w3, w3, #'0'      // Convertir ASCII a número (0 o 1)
        lsl x2, x2, #1        // Desplaza acumulador a la izquierda
        orr x2, x2, x3        // Agrega bit
        b loop

convertir:
        // x2 tiene el decimal, convertir a ASCII en buffer
        mov x1, x2           // x1 = número
        ldr x2, =buffer      // x2 = puntero al buffer
        bl int_to_str        // Convertir entero a cadena

        // Imprimir resultado
        ldr x0, =buffer
        bl print_str

        // Salir
        mov x8, #93
        mov x0, #0
        svc 0

// ------------------------------------
// Subrutina: int_to_str
// Entrada: x1 = número, x2 = buffer
// Salida: buffer con cadena ASCII
// ------------------------------------
int_to_str:
        mov x3, #10        // base 10
        mov x4, x2         // ptr al buffer
.reverse_loop:
        udiv x5, x1, x3
        msub x6, x5, x3, x1  // x6 = x1 - x5*10 (resto)
        add x6, x6, #'0'
        strb w6, [x4], #1
        mov x1, x5
        cbnz x1, .reverse_loop

        // invertir cadena
        sub x4, x4, x2      // longitud
        sub x4, x4, #1
        mov x5, x2
.reverse:
        ldrb w6, [x5]
        ldrb w7, [x2, x4]
        strb w7, [x5], #1
        strb w6, [x2, x4]
        subs x4, x4, #1
        b.gt .reverse
        ret

// ------------------------------------
// Subrutina: print_str (imprime cadena null-terminada)
// Entrada: x0 = puntero a cadena
// ------------------------------------
print_str:
        mov x1, x0          // x1 = cadena
        mov x2, #0
.count_loop:
        ldrb w3, [x1, x2]
        cbz w3, .print
        add x2, x2, #1
        b .count_loop
.print:
        mov x8, #64         // write
        mov x1, x0          // buffer
        mov x0, #1          // stdout
        svc 0
        ret
