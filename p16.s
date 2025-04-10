    // ===============================
    // Programa: Calcular la longitud de una cadena
    // Autor: Perez Garcia Cesar Michael
    // Descripción: Calcula la longitud de una cadena ASCII terminada en NULL,
    //              convierte el valor (número) a ASCII y lo imprime.
    // ===============================

    .section .data
    .align 3
cadena:
    .asciz "1234567890"              // Cadena de ejemplo (terminada en NULL)
msg:
    .asciz "Longitud de la cadena: "
newline:
    .asciz "\n"
buffer:
    .space  20                      // Espacio para almacenar el número convertido a ASCII

    .section .text
    .global _start

// Punto de entrada (sin depender de libc)
_start:
    bl main                        // Llamamos a main
    // Al regresar, x0 contiene el código de salida; llamamos a exit:
    mov     x8, #93                // Syscall exit (93 en aarch64)
    svc     0

// =================================================
// main: Calcula la longitud, la convierte e imprime.
main:
    // --- Calcular longitud de la cadena ---
    adrp    x0, cadena
    add     x0, x0, :lo12:cadena
    bl      longitud_cadena        // Devuelve longitud en x0
    // Conservamos la longitud en x3 para conversión.
    mov     x3, x0

    // --- Convertir número a cadena ASCII ---
    // Preparamos el buffer: x1 = dirección final (buffer + 20)
    adrp    x1, buffer
    add     x1, x1, :lo12:buffer
    add     x1, x1, #20            // x1 apunta al final del buffer
    // Mueve el número a convertir a x0 (ya está en x3)
    mov     x0, x3
    bl      int_to_ascii         // Retorna en x0 el puntero al inicio de la cadena ASCII resultante
    mov     x4, x0               // x4 = puntero a la cadena resultante

    // --- Imprimir mensaje, número convertido y salto de línea ---
    // 1) Imprimir mensaje fijo
    adrp    x0, msg
    add     x0, x0, :lo12:msg
    bl      print_string

    // 2) Imprimir el número (cadena ASCII)
    mov     x0, x4
    bl      print_string

    // 3) Imprimir salto de línea
    adrp    x0, newline
    add     x0, x0, :lo12:newline
    bl      print_string

    // Retornamos 0 (para exit)
    mov     x0, #0
    ret

// =================================================
// longitud_cadena:
// Calcula la longitud de una cadena ASCII terminada en NULL.
// Entrada:  x0 = puntero a la cadena
// Salida:   x0 = longitud (entero)
longitud_cadena:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    mov     x1, #0                // Contador

.long_loop:
    ldrb    w2, [x0, x1]          // Leer byte de la cadena
    cbz     w2, .long_done        // Si es NULL, finaliza
    add     x1, x1, #1            // Incrementar contador
    b       .long_loop
.long_done:
    mov     x0, x1                // Devuelve la longitud en x0
    ldp     x29, x30, [sp], #16
    ret

// =================================================
// print_string:
// Imprime en pantalla una cadena ASCII terminada en NULL utilizando la syscall write.
// Entrada: x0 = puntero a la cadena.
print_string:
    // Usaremos x9 para recorrer la cadena sin modificar x0.
    mov     x9, x0               // Guardamos el puntero original
    mov     x2, #0               // Contador de longitud

.print_loop:
    ldrb    w3, [x9, x2]         // Leer byte en [x9 + x2]
    cmp     w3, #0
    beq     .print_done
    add     x2, x2, #1
    b       .print_loop
.print_done:
    // Syscall write: FD=1 (stdout), cadena en x0, longitud en x2.
    mov     x7, #1               // FD = 1
    mov     x8, #64              // Syscall write (64 en aarch64)
    svc     0
    ret

// =================================================
// int_to_ascii:
// Convierte un número entero (en x0) a una cadena ASCII (base 10).
// Se escribe en un buffer apuntado por x1 (inicialmente el final del buffer) decrementando el puntero.
// Entrada:  x0 = número a convertir
//           x1 = puntero al final del buffer (buffer + tamaño)
// Salida:   x0 = puntero al inicio de la cadena resultante en el buffer
int_to_ascii:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    mov     x5, #10              // Divisor base 10

    cmp     x0, #0
    b.ne    .int_loop_correct
    // Caso especial: número es 0
    sub     x1, x1, #1
    mov     w4, #'0'
    strb    w4, [x1]
    b       .int_conv_done

.int_loop_correct:
    // Mientras el número no sea cero:
.int_loop:
    udiv    x3, x0, x5           // x3 = cociente
    msub    x4, x0, x3, x5       // x4 = residuo = x0 - (x3 * 10)
    add     x4, x4, #'0'         // Convertir residuo a carácter ASCII
    sub     x1, x1, #1           // Decrementar el puntero (escribimos de derecha a izquierda)
    strb    w4, [x1]             // Almacenar el dígito (w4 contiene el valor de x4)
    mov     x0, x3               // Actualiza x0 con el cociente para la siguiente iteración
    cmp     x0, #0
    b.ne    .int_loop
.int_conv_done:
    mov     x0, x1               // Resultado: puntero al inicio de la cadena ASCII
    ldp     x29, x30, [sp], #16
    ret
