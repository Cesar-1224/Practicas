/*
# =========================================
# Programa: Calcular la longitud de una cadena
# Autor: Perez Garcia Cesar Michael
# Descripción: Calcular la longitud de una cadena
# =========================================
*/
.data
    cadena:     .asciz "1234567890"     // Cadena de ejemplo de números
    msg1:       .asciz "Longitud de la cadena: "
    msg2:       .asciz "\n"
    buffer:     .space 20      // Buffer para conversión de números

.text
.global _start
.align 2

/* Función para imprimir texto */
print_string:
    // Parámetros:
    // x0 = dirección de la cadena
    mov     x2, #0          // Contador de longitud
count_loop:
    ldrb    w1, [x0, x2]    // Cargar byte
    cbz     w1, print_now   // Si es 0, terminar conteo
    add     x2, x2, #1      // Incrementar contador
    b       count_loop
    
print_now:
    mov     x1, x0          // Dirección de la cadena
    mov     x8, #64         // syscall write
    mov     x0, #1          // stdout
    svc     #0
    ret

/* Función para imprimir un número entero */
print_int:
    // x0 = número entero a imprimir
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    // Usar buffer global en lugar de stack
    adrp    x1, buffer
    add     x1, x1, :lo12:buffer
    
    // Si es 0, caso especial
    cmp     x0, #0
    bne     not_zero
    
    mov     w2, #'0'        // Carácter '0'
    strb    w2, [x1]        // Guardar en buffer
    mov     w2, #0          // Terminador nulo
    strb    w2, [x1, #1]    // Guardar después del '0'
    mov     x0, x1          // Dirección del buffer
    bl      print_string    // Imprimir
    b       print_int_done
    
not_zero:
    mov     x3, #0          // Índice en el buffer
    mov     x4, #10         // Base 10
    
    // Si es negativo, manejar el signo
    cmp     x0, #0
    bge     positive
    
    neg     x0, x0          // Hacer positivo
    mov     w2, #'-'        // Carácter '-'
    strb    w2, [x1, x3]    // Guardar en buffer
    add     x3, x3, #1      // Avanzar índice
    
positive:
    // Necesitamos convertir los dígitos en orden inverso
    // Usaremos un segundo buffer temporal
    add     x5, x1, #10     // Buffer temporal (segunda mitad)
    mov     x6, #0          // Contador de dígitos
    
digit_loop:
    udiv    x7, x0, x4      // x7 = x0 / 10
    msub    x8, x7, x4, x0  // x8 = x0 - (x7 * 10) = dígito
    
    add     w8, w8, #'0'    // Convertir a ASCII
    strb    w8, [x5, x6]    // Guardar en buffer temporal
    add     x6, x6, #1      // Incrementar contador
    
    mov     x0, x7          // Preparar para siguiente iteración
    cbnz    x0, digit_loop  // Si no es 0, continuar
    
    // Ahora copiamos los dígitos en orden inverso al buffer final
    sub     x6, x6, #1      // Ajustar para índice basado en 0
    
reverse_loop:
    ldrb    w8, [x5, x6]    // Cargar dígito
    strb    w8, [x1, x3]    // Guardar en buffer final
    add     x3, x3, #1      // Avanzar índice buffer final
    subs    x6, x6, #1      // Retroceder índice buffer temporal
    bpl     reverse_loop    // Si >= 0, continuar
    
    // Agregar terminador nulo
    mov     w8, #0
    strb    w8, [x1, x3]
    
    // Imprimir el resultado
    mov     x0, x1
    bl      print_string
    
print_int_done:
    ldp     x29, x30, [sp], #16
    ret

_start:
    // Cargar la dirección de la cadena
    adrp    x0, cadena
    add     x0, x0, :lo12:cadena
    
    // Llamar a la función que calcula la longitud
    bl      longitud_cadena
    mov     x19, x0                 // Guardar resultado
    
    // Imprimir mensaje
    adrp    x0, msg1
    add     x0, x0, :lo12:msg1
    bl      print_string
    
    // Imprimir el resultado numérico
    mov     x0, x19                 // Cargar resultado
    bl      print_int
    
    // Imprimir nueva línea
    adrp    x0, msg2
    add     x0, x0, :lo12:msg2
    bl      print_string
    
    // Salir del programa
    mov     x8, #93                 // syscall exit
    mov     x0, #0                  // código de retorno
    svc     #0

// Función longitud_cadena
// Entrada: x0 = dirección de la cadena a medir
// Salida:  x0 = longitud de la cadena
longitud_cadena:
    mov     x1, #0                    // x1 será nuestro contador de longitud
loop:
    ldrb    w2, [x0, x1]              // Leer un byte de la cadena
    cbz     w2, fin                   // Si es NULL (fin de cadena), salir
    add     x1, x1, #1                // Incrementar contador
    b       loop                      // Repetir el bucle
fin:
    mov     x0, x1                    // Mover longitud a x0 como resultado
    ret
