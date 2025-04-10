/*
# =========================================
# Programa: Conversión de ASCII a entero
# Autor: Perez Garcia Cesar Michael
# Descripción: Conversión de ASCII a entero
# =========================================
*/
.data
    // Cadena de dígitos ASCII de entrada
    ascii_str:   .asciz "2145"
    // Mensajes para imprimir
    msg1:        .asciz "Resultado de la conversión: "
    msg2:        .asciz "\n"
    buffer:      .space 20      // Buffer para conversión de números

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
    // Preparar parámetros para conversión de ASCII a entero
    adrp    x0, ascii_str
    add     x0, x0, :lo12:ascii_str
    bl      ascii_to_int
    
    // Guardar resultado
    mov     x19, x0
    
    // Imprimir mensaje de resultado
    adrp    x0, msg1
    add     x0, x0, :lo12:msg1
    bl      print_string
    
    // Imprimir número entero convertido
    mov     x0, x19
    bl      print_int
    
    // Imprimir nueva línea
    adrp    x0, msg2
    add     x0, x0, :lo12:msg2
    bl      print_string
    
    // Salir del programa
    mov     x8, #93         // syscall exit
    mov     x0, #0          // código de retorno
    svc     #0

// Función para convertir cadena ASCII a entero
// Entrada: x0 = dirección de la cadena ASCII
// Salida:  x0 = valor entero convertido
ascii_to_int:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    mov     x1, #0          // Inicializar acumulador de resultado
loop:
    ldrb    w2, [x0], #1    // Cargar siguiente byte de la cadena y avanzar
    cmp     w2, #0          // ¿Es el final de la cadena?
    b.eq    end_conversion  // Si es cero, fin de la conversión
    sub     w2, w2, #'0'    // Convertir ASCII a valor numérico
    
    // Multiplicar el acumulador por 10 y sumar dígito
    mov     x3, #10
    mul     x1, x1, x3
    add     x1, x1, x2, SXTW // Sumar el dígito (con extensión de signo)
    
    b       loop            // Repetir con el siguiente carácter
end_conversion:
    mov     x0, x1          // Mover resultado a x0 como valor de retorno
    
    ldp     x29, x30, [sp], #16
    ret
