// ===============================================
// Estudiante y No de control: Perez Garcia Cesar Michael
// Descripcion: Programa en ensamblador ARM64 para obtener la serie de fibonacci
// Practica: p23
// ===============================================

.data
prompt:      .asciz "Introduce el numero de terminos de la serie de Fibonacci: "
term_msg:    .asciz "Termino "
term_value:  .asciz ": "
newline:     .asciz "\n"
buffer:      .space 16
terms:       .quad 0

.text
.global _start

_start:
    // Mostrar prompt
    mov x0, #1                 // fd = 1 (stdout)
    ldr x1, =prompt            // buffer = prompt
    mov x2, #57                // count = longitud del prompt
    mov x8, #64                // syscall = write
    svc #0                     // llamada al sistema

    // Leer la entrada
    mov x0, #0                 // fd = 0 (stdin)
    ldr x1, =buffer            // buffer para entrada
    mov x2, #16                // tamaño máximo
    mov x8, #63                // syscall = read
    svc #0                     // llamada al sistema

    // Procesar entrada (convertir ASCII a entero)
    mov x9, #0                 // Inicializar contador de términos
    ldr x1, =buffer
    mov x2, #0                 // Valor acumulado

read_loop:
    ldrb w3, [x1], #1          // Cargar byte y avanzar puntero
    cmp w3, #10                // Verificar si es nueva línea
    beq end_read
    cmp w3, #13                // Verificar si es retorno de carro
    beq end_read
    cmp w3, #0                 // Verificar si es nulo
    beq end_read
    cmp w3, #48                // Verificar si es menor que '0'
    blt read_loop
    cmp w3, #57                // Verificar si es mayor que '9'
    bgt read_loop
    
    sub w3, w3, #48            // Convertir ASCII a número
    mov x4, #10
    mul x2, x2, x4             // Multiplicar valor actual por 10
    add x2, x2, x3             // Añadir nuevo dígito
    b read_loop

end_read:
    // Almacenar número de términos
    ldr x0, =terms
    str x2, [x0]
    
    // Verificar que sea > 0
    cmp x2, #0
    ble exit_program
    
    // Inicializar valores de Fibonacci
    mov x19, #0                // Primer término (0)
    mov x20, #1                // Segundo término (1)
    mov x21, #0                // Índice del término actual

    // Si el usuario pidió 0 términos, salir
    cmp x2, #0
    beq exit_program

fibonacci_loop:
    // Imprimir "Termino X: "
    mov x0, #1                 // fd = 1 (stdout)
    ldr x1, =term_msg          // "Termino "
    mov x2, #8                 // longitud
    mov x8, #64                // syscall = write
    svc #0
    
    // Convertir índice (x21) a ASCII para imprimir
    add x3, x21, #48           // Convertir a ASCII
    mov x0, #1                 // fd = 1
    mov x1, sp                 // Usar stack para almacenar temporalmente
    strb w3, [x1]              // Guardar byte en stack
    mov x2, #1                 // Un byte
    mov x8, #64                // syscall = write
    svc #0
    
    // Imprimir ": "
    mov x0, #1                 // fd = 1
    ldr x1, =term_value        // ": "
    mov x2, #2                 // longitud
    mov x8, #64                // syscall = write
    svc #0
    
    // En la primera iteración, imprimir 0
    cmp x21, #0
    bne not_first_term
    
    mov x3, #48                // '0' en ASCII
    mov x0, #1                 // fd = 1
    mov x1, sp                 // Usar stack
    strb w3, [x1]              // Guardar byte
    mov x2, #1                 // Un byte
    mov x8, #64                // syscall = write
    svc #0
    
    // Imprimir nueva línea
    mov x0, #1                 // fd = 1
    ldr x1, =newline           // "\n"
    mov x2, #1                 // longitud
    mov x8, #64                // syscall = write
    svc #0
    
    // Incrementar contador e índice
    add x21, x21, #1           // Incrementar índice
    cmp x21, x2                // Comparar con total de términos
    bge exit_program           // Si hemos terminado, salir
    b fibonacci_loop
    
not_first_term:
    // Para el segundo término y posteriores
    cmp x21, #1
    bne not_second_term
    
    // Imprimir "1"
    mov x3, #49                // '1' en ASCII
    mov x0, #1                 // fd = 1
    mov x1, sp                 // Usar stack
    strb w3, [x1]              // Guardar byte
    mov x2, #1                 // Un byte
    mov x8, #64                // syscall = write
    svc #0
    
    // Imprimir nueva línea
    mov x0, #1                 // fd = 1
    ldr x1, =newline           // "\n"
    mov x2, #1                 // longitud
    mov x8, #64                // syscall = write
    svc #0
    
    // Incrementar contador e índice
    add x21, x21, #1           // Incrementar índice
    cmp x21, x2                // Comparar con total de términos
    bge exit_program           // Si hemos terminado, salir
    b fibonacci_loop

not_second_term:
    // Calcular siguiente número de Fibonacci
    add x22, x19, x20          // x22 = x19 + x20
    mov x19, x20               // x19 = x20
    mov x20, x22               // x20 = x22
    
    // Convertir número a ASCII e imprimir
    // Esta es una implementación simple que solo maneja números pequeños
    mov x3, x22
    add x3, x3, #48            // Convertir a ASCII
    mov x0, #1                 // fd = 1
    mov x1, sp                 // Usar stack
    strb w3, [x1]              // Guardar byte
    mov x2, #1                 // Un byte
    mov x8, #64                // syscall = write
    svc #0
    
    // Imprimir nueva línea
    mov x0, #1                 // fd = 1
    ldr x1, =newline           // "\n"
    mov x2, #1                 // longitud
    mov x8, #64                // syscall = write
    svc #0
    
    // Incrementar contador e índice
    add x21, x21, #1           // Incrementar índice
    ldr x4, =terms
    ldr x2, [x4]               // Cargar número total de términos
    cmp x21, x2                // Comparar con total de términos
    blt fibonacci_loop         // Si no hemos terminado, siguiente término

exit_program:
    // Terminar programa
    mov x0, #0                 // código de salida
    mov x8, #93                // syscall = exit
    svc #0
