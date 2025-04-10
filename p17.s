/*
Programa: Contar vocales y consonantes
Autor: Perez Garcia Cesar Michael
Descripción: Cuenta el número de vocales y consonantes en una cadena ASCII terminada en NULL,
             convierte cada contador a cadena ASCII y los imprime usando syscalls.
*/

    .section .data
    .align 3
cadena:           .asciz "Hello World"           // Cadena de ejemplo
msg_vocales:      .asciz "Número de vocales: "
msg_consonantes:  .asciz "Número de consonantes: "
newline:          .asciz "\n"
buffer:           .space  20                     // Área para conversión numérica a ASCII

    .section .text
    .global _start

// Punto de entrada del programa (sin depender de libc)
_start:
    bl main
    mov     x8, #93            // Syscall exit (93 en ARM64)
    svc     0

// ------------------------------------------------------------------------
// main:
// 1. Llama a contar_vocales_consonantes, donde: x2 = vocales, x3 = consonantes.
// 2. Imprime mensaje y el número (convertido a ASCII) para vocales y consonantes.
// 3. Imprime saltos de línea.
main:
    // --- Contar vocales y consonantes ---
    adrp    x0, cadena
    add     x0, x0, :lo12:cadena
    bl      contar_vocales_consonantes   // x2: vocales, x3: consonantes

    // Guardar los contadores en x5 (vocales) y x6 (consonantes)
    mov     x5, x2
    mov     x6, x3

    // --- Imprimir número de vocales ---
    // Imprime mensaje fijo
    adrp    x0, msg_vocales
    add     x0, x0, :lo12:msg_vocales
    bl      print_nt_string

    // Convertir contador de vocales a cadena ASCII.
    adrp    x1, buffer
    add     x1, x1, :lo12:buffer
    add     x1, x1, #20            // x1 apunta al final del buffer
    mov     x0, x5                // Número a convertir (vocales)
    bl      int_to_ascii          // Retorna en x0 el puntero al inicio de la cadena ASCII
    // Calcular la longitud: (buffer+20) - (puntero devuelto)
    adrp    x7, buffer
    add     x7, x7, :lo12:buffer
    add     x7, x7, #20           // x7 = buffer + 20 (fin del área)
    sub     x2, x7, x0            // x2 = longitud de la cadena convertida
    // Imprimir la representación numérica con longitud conocida.
    mov     x0, x0                // Dirección de la cadena convertida
    bl      print_with_len

    // Imprime salto de línea.
    adrp    x0, newline
    add     x0, x0, :lo12:newline
    bl      print_nt_string

    // --- Imprimir número de consonantes ---
    // Imprime mensaje fijo
    adrp    x0, msg_consonantes
    add     x0, x0, :lo12:msg_consonantes
    bl      print_nt_string

    // Convertir contador de consonantes a cadena ASCII.
    adrp    x1, buffer
    add     x1, x1, :lo12:buffer
    add     x1, x1, #20           // x1 apunta al final del buffer
    mov     x0, x6                // Número a convertir (consonantes)
    bl      int_to_ascii          // Retorna en x0 el puntero al inicio de la cadena ASCII
    // Calcular la longitud de la representación convertida.
    adrp    x7, buffer
    add     x7, x7, :lo12:buffer
    add     x7, x7, #20
    sub     x2, x7, x0
    mov     x0, x0
    bl      print_with_len

    // Imprime salto de línea.
    adrp    x0, newline
    add     x0, x0, :lo12:newline
    bl      print_nt_string

    mov     x0, #0                // Código de salida 0
    ret

// ------------------------------------------------------------------------
// contar_vocales_consonantes:
// Recorre la cadena y cuenta vocales (x2) y consonantes (x3).
// Entrada:  x0 = dirección de la cadena
// Salida:   x2 = número de vocales, x3 = número de consonantes
contar_vocales_consonantes:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    mov     x2, #0                // Inicializar contador de vocales
    mov     x3, #0                // Inicializar contador de consonantes
cont_loop:
    ldrb    w1, [x0], #1          // Cargar un byte y avanzar el puntero
    cbz     w1, cont_end          // Si es NULL, terminar
    // Convertir mayúsculas a minúsculas si el carácter es 'A'..'Z'
    cmp     w1, #'A'
    blt     cont_no_conv
    cmp     w1, #'Z'
    bgt     cont_no_conv
    add     w1, w1, #'a' - 'A'
cont_no_conv:
    // Verificar si es vocal: 'a', 'e', 'i', 'o', 'u'
    cmp     w1, #'a'
    beq     inc_vowel
    cmp     w1, #'e'
    beq     inc_vowel
    cmp     w1, #'i'
    beq     inc_vowel
    cmp     w1, #'o'
    beq     inc_vowel
    cmp     w1, #'u'
    beq     inc_vowel
    // Si es letra (entre 'a' y 'z') se considera consonante.
    cmp     w1, #'a'
    blt     cont_loop
    cmp     w1, #'z'
    bgt     cont_loop
    add     x3, x3, #1
    b       cont_loop
inc_vowel:
    add     x2, x2, #1
    b       cont_loop
cont_end:
    ldp     x29, x30, [sp], #16
    ret

// ------------------------------------------------------------------------
// int_to_ascii:
// Convierte un número entero (en x0) a una cadena ASCII en base 10.
// Usa el buffer apuntado por x1 (que debe apuntar al final del área).
// Salida: x0 = puntero al inicio de la cadena resultante.
// Se escribe el dígito menos significativo primero (de derecha a izquierda).
int_to_ascii:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    mov     x5, #10             // Divisor para base 10
    cmp     x0, #0
    b.ne    int_loop
    // Caso especial: si el número es 0.
    sub     x1, x1, #1
    mov     w4, #'0'
    strb    w4, [x1]
    b       int_done
int_loop:
    udiv    x3, x0, x5          // x3 = cociente
    msub    x6, x0, x3, x5      // x6 = residuo (nuevo registro para preservar resultado)
    add     x6, x6, #'0'        // Convertir residuo a carácter ASCII (almacena en x6)
    sub     x1, x1, #1          // Decrementar puntero de escritura
    strb    w6, [x1]           // Almacenar el dígito (w6 contiene el ASCII)
    mov     x0, x3            // Actualizar x0 con el cociente
    cmp     x0, #0
    b.ne    int_loop
int_done:
    mov     x0, x1              // x0 = puntero al inicio de la cadena resultante
    ldp     x29, x30, [sp], #16
    ret

// ------------------------------------------------------------------------
// print_nt_string:
// Imprime una cadena ASCII terminada en NULL usando la syscall write.
// Entrada: x0 = puntero a la cadena.
print_nt_string:
    mov     x1, x0              // x1 = puntero a la cadena
    mov     x2, #0              // Contador de longitud
pt_loop:
    ldrb    w3, [x1, x2]
    cmp     w3, #0
    beq     pt_done
    add     x2, x2, #1
    b       pt_loop
pt_done:
    mov     x7, #1              // FD = 1 (stdout)
    mov     x8, #64             // Syscall write (64 en ARM64)
    svc     0
    ret

// ------------------------------------------------------------------------
// print_with_len:
// Imprime una cadena de longitud conocida.
// Entrada: x0 = puntero a la cadena, x2 = longitud.
print_with_len:
    mov     x7, #1              // FD = 1
    mov     x8, #64             // Syscall write
    svc     0
    ret
