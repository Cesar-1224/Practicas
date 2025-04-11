/*
 * =========================================
 * Programa: Desplazamientos a la izquierda y derecha (p19)
 * Autor: Perez Garcia Cesar Michael
 * Descripcion: Realiza desplazamientos a la izquierda y a la derecha en una cadena
 * ingresada por el usuario
 * =========================================
 */
.section .data
    prompt:           .asciz "Ingrese una cadena de texto: "
    cadena:           .space 100               // Espacio para la cadena de entrada
    msg_char:         .asciz "Caracter: '"
    msg_char_end:     .asciz "' (ASCII: "
    msg_shift_left:   .asciz "Desplazamiento Izq: "
    msg_shift_right:  .asciz "Desplazamiento Der: "
    msg_separator:    .asciz "-------------------------\n"
    newline:          .asciz "\n"
    close_paren:      .asciz ")\n"
    buffer:           .space 16                // Buffer para convertir números a texto

.section .text
.global _start
.align 2
_start:
    // Mostrar prompt para ingresar la cadena
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =prompt             // Mensaje de prompt
    mov     x2, #27                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Leer entrada del usuario
    mov     x0, #0                  // File descriptor 0 (stdin)
    ldr     x1, =cadena             // Buffer para almacenar la entrada
    mov     x2, #100                // Tamaño máximo de lectura
    mov     x8, #63                 // syscall read
    svc     #0
    
    // Guardar longitud de la cadena leída
    mov     x19, x0                 // Guardar longitud de la cadena
    
    // Terminar la cadena con NULL
    ldr     x1, =cadena
    add     x1, x1, x19             // Posición final
    mov     w2, #0
    strb    w2, [x1]                // Añadir terminador NULL
    
    // Cargar la dirección de la cadena
    ldr     x0, =cadena
    mov     x1, x19                 // Pasar longitud de la cadena
    bl      desplazamientos
    
    // Salir del programa
    mov     x0, #0                  // Código de salida
    mov     x8, #93                 // syscall exit
    svc     #0

// Función desplazamientos
// Entrada: x0 = dirección de la cadena, x1 = longitud de la cadena
desplazamientos:
    // Guardamos x0 como dirección inicial de la cadena
    mov     x19, x0                 // Dirección inicial de cadena
    mov     x20, x1                 // Longitud de la cadena
    mov     x21, #0                 // Contador
    
loop:
    cmp     x21, x20                // Comparar contador con longitud
    beq     fin                     // Si hemos procesado toda la cadena, salir
    
    ldrb    w22, [x19, x21]         // Leer un byte de la cadena
    add     x21, x21, #1            // Incrementar contador
    
    // Realizar los desplazamientos
    lsl     w23, w22, #1            // Desplazamiento a la izquierda en 1 bit
    lsr     w24, w22, #1            // Desplazamiento a la derecha en 1 bit
    
    // Imprimir "Caracter: '"
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_char           // Mensaje
    mov     x2, #11                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir el carácter
    mov     x0, #1                  // File descriptor 1 (stdout)
    mov     x1, x19                 // Dirección de la cadena
    add     x1, x1, x21             // Ajustar a posición actual
    sub     x1, x1, #1              // Retroceder 1 para el carácter actual
    mov     x2, #1                  // Imprimir 1 carácter
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir "' (ASCII: "
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_char_end       // Mensaje
    mov     x2, #10                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Convertir valor ASCII a texto y mostrarlo
    mov     x1, x22                 // Valor ASCII a convertir
    ldr     x2, =buffer             // Buffer para el resultado
    bl      int_to_str              // Convertir a texto
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =buffer             // Buffer con número
    mov     x2, #16                 // Longitud máxima
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir paréntesis de cierre y salto de línea
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =close_paren        // Mensaje
    mov     x2, #2                  // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir el resultado del desplazamiento a la izquierda
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_shift_left     // Mensaje
    mov     x2, #19                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x1, x23                 // Valor del desplazamiento izquierdo
    ldr     x2, =buffer             // Buffer para el resultado
    bl      int_to_str              // Convertir a texto
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =buffer             // Buffer con número
    mov     x2, #16                 // Longitud máxima
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =newline            // Salto de línea
    mov     x2, #1                  // Longitud
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir el resultado del desplazamiento a la derecha
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_shift_right    // Mensaje
    mov     x2, #19                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x1, x24                 // Valor del desplazamiento derecho
    ldr     x2, =buffer             // Buffer para el resultado
    bl      int_to_str              // Convertir a texto
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =buffer             // Buffer con número
    mov     x2, #16                 // Longitud máxima
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =newline            // Salto de línea
    mov     x2, #1                  // Longitud
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir separador
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_separator      // Mensaje separador
    mov     x2, #26                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    b       loop
    
fin:
    ret

// Función int_to_str para convertir entero a string
// Entrada: x1 = número a convertir, x2 = buffer para resultado
// Salida: buffer en x2 contiene el número convertido a texto
int_to_str:
    mov     x3, #10        // Divisor
    mov     x4, x2         // Guardar puntero inicial
    mov     x5, #0         // Contador de dígitos
    
    // Manejar caso especial de 0
    cmp     x1, #0
    bne     check_sign
    
    mov     w6, #'0'
    strb    w6, [x4]
    mov     w6, #0         // Terminar con NULL
    strb    w6, [x4, #1]
    ret
    
check_sign:
    // Verificar si es negativo
    cmp     x1, #0
    bge     convert_digits
    
    // Si es negativo, escribir el signo '-'
    mov     w6, #'-'
    strb    w6, [x4], #1
    neg     x1, x1         // Hacer positivo el número
    
convert_digits:
    // Guardar la posición inicial para invertir después
    mov     x7, x4
    
digit_loop:
    // Dividir por 10 para obtener último dígito
    udiv    x6, x1, x3     // x6 = x1 / 10
    msub    x8, x6, x3, x1 // x8 = x1 - (x6 * 10) = x1 % 10
    
    // Convertir dígito a ASCII
    add     w8, w8, #'0'
    strb    w8, [x4], #1   // Almacenar dígito y avanzar
    
    // Actualizar contador
    add     x5, x5, #1
    
    // Verificar si terminamos
    mov     x1, x6
    cbnz    x1, digit_loop
    
    // Terminar con NULL
    mov     w6, #0
    strb    w6, [x4]
    
    ret
