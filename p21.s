/*
 * =========================================
 * Programa: Resta de dos numeros con entrada (p21)
 * Autor: Perez Garcia Cesar Michael
 * Descripcion: Solicita dos numeros al usuario, los resta y muestra el resultado en consola
 * =========================================
 */

.section .data
prompt1: .asciz "Ingrese el primer numero: "
prompt2: .asciz "Ingrese el segundo numero: "
resultado: .asciz "Resultado de la resta: "
buffer:   .space 16                 // Espacio para almacenar la entrada del usuario y el resultado

.section .text
.global _start

_start:
    // Mostrar mensaje para el primer número
    mov x0, #1                  // File descriptor 1 (salida estándar)
    ldr x1, =prompt1            // Mensaje para el primer número
    mov x2, #26                 // Longitud del mensaje
    mov x8, #64                 // Syscall de write
    svc 0

    // Leer el primer número desde la entrada estándar
    mov x0, #0                  // File descriptor 0 (entrada estándar)
    ldr x1, =buffer             // Guardar en buffer
    mov x2, #15                 // Tamaño máximo de entrada
    mov x8, #63                 // Syscall de read
    svc 0

    // Convertir el primer número leído a entero
    ldr x1, =buffer             // Dirección del buffer donde está el número en texto
    bl str_to_int               // Llamada a subrutina para convertir a entero en x0
    mov x9, x0                  // Guardar primer número en x9

    // Mostrar mensaje para el segundo número
    mov x0, #1                  // File descriptor 1 (salida estándar)
    ldr x1, =prompt2            // Mensaje para el segundo número
    mov x2, #27                 // Longitud del mensaje
    mov x8, #64                 // Syscall de write
    svc 0

    // Leer el segundo número desde la entrada estándar
    mov x0, #0                  // File descriptor 0 (entrada estándar)
    ldr x1, =buffer             // Guardar en buffer
    mov x2, #15                 // Tamaño máximo de entrada
    mov x8, #63                 // Syscall de read
    svc 0

    // Convertir el segundo número leído a entero
    ldr x1, =buffer             // Dirección del buffer donde está el número en texto
    bl str_to_int               // Llamada a subrutina para convertir a entero en x0
    
    // Invertir los valores para la resta (corregido)
    mov x10, x0                 // Guardar segundo número en x10
    mov x0, x10                 // Mover segundo número a x0
    sub x0, x0, x9              // Restar el primer número (x9) del segundo número (x0)

    // Convertir el resultado a texto en buffer
    mov x1, x0                  // Pasar el resultado de la resta a x1 para conversión
    ldr x2, =buffer             // Dirección del buffer para el resultado
    bl int_to_str               // Convertir número a texto

    // Imprimir el texto del resultado
    mov x0, #1                  // File descriptor 1 (salida estándar)
    ldr x1, =resultado          // Mensaje de "Resultado de la resta: "
    mov x2, #23                 // Longitud del mensaje
    mov x8, #64                 // Syscall de write
    svc 0

    // Imprimir el valor convertido
    mov x0, #1                  // File descriptor 1 (salida estándar)
    ldr x1, =buffer             // Dirección del buffer que contiene el número
    mov x2, #12                 // Longitud máxima del resultado
    mov x8, #64                 // Syscall de write
    svc 0

    // Terminar el programa
    mov x8, #93                 // Syscall para "exit"
    mov x0, #0                  // Código de salida 0 (éxito)
    svc 0

// =========================================
// Subrutina: str_to_int (Convierte cadena en x1 a entero en x0)
// =========================================
str_to_int:
    mov x0, #0                  // Inicializa el resultado en 0
    mov x2, #10                 // Base decimal
    
convert_loop:
    ldrb w3, [x1], #1           // Leer siguiente byte de la cadena
    cmp w3, #10                 // Verificar salto de línea (ASCII 10)
    beq end_convert             // Si es salto de línea, termina conversión
    sub w3, w3, #'0'            // Convertir de ASCII a dígito
    mul x0, x0, x2              // Multiplica el resultado actual por 10
    add x0, x0, x3              // Sumar el dígito actual
    b convert_loop
    
end_convert:
    ret

// =========================================
// Subrutina: int_to_str (Convierte entero en x1 a cadena en x2)
// =========================================
int_to_str:
    mov x3, #10                 // Divisor
    mov x0, x2                  // Guardar puntero inicial del buffer
    mov x6, #0                  // Contador de dígitos
    
    // Caso especial para 0
    cmp x1, #0
    bne check_negative
    mov w4, #'0'
    strb w4, [x2], #1
    mov w4, #10                 // Agregar salto de línea
    strb w4, [x2], #1
    ret
    
check_negative:
    // Verificar si el número es negativo
    cmp x1, #0
    bge positive_conversion
    
    // Si es negativo, escribir el signo y hacer positivo el número
    mov w4, #'-'
    strb w4, [x2], #1
    neg x1, x1
    
positive_conversion:
    // Mover el puntero al final para escribir los dígitos en orden inverso
    mov x4, x2                  // Guardar posición actual
    
digit_loop:
    udiv x7, x1, x3             // Dividir entre 10
    msub x8, x7, x3, x1         // Obtener resto (dígito)
    add x8, x8, #'0'            // Convertir a ASCII
    strb w8, [x2], #1           // Almacenar dígito y avanzar
    add x6, x6, #1              // Incrementar contador de dígitos
    mov x1, x7                  // Actualizar número
    cbnz x1, digit_loop         // Continuar si quedan dígitos
    
    // Agregar salto de línea
    mov w8, #10
    strb w8, [x2], #1
    
    ret
