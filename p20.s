/*
 * =========================================
 * Programa: Establecer, borrar y alternar bits (p20)
 * Autor: Perez Garcia Cesar Michael
 * Descripcion: Realiza operaciones para establecer, borrar y alternar bits
 * en una cadena ingresada por el usuario
 * =========================================
 */
.section .data
    prompt:             .asciz "Ingrese una cadena de texto: "
    cadena:             .space 100                  // Espacio para la cadena de entrada
    msg_set_bits:       .asciz "Bits establecidos: "
    msg_clear_bits:     .asciz "Bits borrados: "
    msg_toggle_bits:    .asciz "Bits alternados: "
    newline:            .asciz "\n"
    buffer:             .space 16                   // Buffer para convertir números a texto

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
    
    // Llamar a la función que establece, borra y alterna bits
    ldr     x0, =cadena
    mov     x1, x19                 // Pasar longitud de la cadena
    bl      modificar_bits
    
    // Guardar resultados
    mov     w19, w2                 // Resultado de establecer bits
    mov     w20, w3                 // Resultado de borrar bits
    mov     w21, w4                 // Resultado de alternar bits
    
    // Imprimir el resultado de establecer bits
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_set_bits       // Mensaje
    mov     x2, #18                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x1, x19                 // Valor para convertir a texto
    ldr     x2, =buffer             // Buffer para el resultado
    bl      int_to_str              // Convertir a texto
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =buffer             // Mensaje
    mov     x2, #16                 // Longitud máxima
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =newline            // Mensaje
    mov     x2, #1                  // Longitud
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir el resultado de borrar bits
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_clear_bits     // Mensaje
    mov     x2, #15                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x1, x20                 // Valor para convertir a texto
    ldr     x2, =buffer             // Buffer para el resultado
    bl      int_to_str              // Convertir a texto
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =buffer             // Mensaje
    mov     x2, #16                 // Longitud máxima
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =newline            // Mensaje
    mov     x2, #1                  // Longitud
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Imprimir el resultado de alternar bits
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =msg_toggle_bits    // Mensaje
    mov     x2, #16                 // Longitud del mensaje
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x1, x21                 // Valor para convertir a texto
    ldr     x2, =buffer             // Buffer para el resultado
    bl      int_to_str              // Convertir a texto
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =buffer             // Mensaje
    mov     x2, #16                 // Longitud máxima
    mov     x8, #64                 // syscall write
    svc     #0
    
    mov     x0, #1                  // File descriptor 1 (stdout)
    ldr     x1, =newline            // Mensaje
    mov     x2, #1                  // Longitud
    mov     x8, #64                 // syscall write
    svc     #0
    
    // Salir del programa
    mov     x0, #0                  // Código de salida
    mov     x8, #93                 // syscall exit
    svc     #0

// Función modificar_bits
// Entrada: x0 = dirección de la cadena, x1 = longitud de la cadena
// Salida: w2 = resultado de establecer bits, w3 = resultado de borrar bits, w4 = resultado de alternar bits
modificar_bits:
    // Inicializar resultados
    mov     w2, #0        // Resultado de establecer bits inicializado a 0
    mov     w3, #0xFF     // Resultado de borrar bits inicializado a 0xFF (todos los bits en 1)
    mov     w4, #0        // Resultado de alternar bits inicializado a 0
    
    mov     x5, #0        // Contador
    
loop:
    cmp     x5, x1        // Comparar contador con longitud
    beq     fin           // Si hemos procesado toda la cadena, salir
    
    ldrb    w6, [x0, x5]  // Leer un byte de la cadena
    add     x5, x5, #1    // Incrementar contador
    
    // Establecer bits: ORR para fijar bits en 1
    orr     w2, w2, w6    // OR bit a bit para establecer bits
    
    // Borrar bits: AND con el complemento para borrar bits
    bic     w3, w3, w6    // BIC borra bits específicos (w3 AND NOT w6)
    
    // Alternar bits: EOR para alternar bits
    eor     w4, w4, w6    // XOR bit a bit para alternar bits
    
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
