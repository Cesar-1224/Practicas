// ===============================================
// Estudiante y No de control: Perez Garcia Cesar Michael
// Descripcion: Programa en ensamblador ARM64 para calcular factorial de un numero
// Practica: p24
// ===============================================

.data
prompt:      .asciz "Introduce un numero para calcular su factorial: "
result_msg1: .asciz "El factorial de "
result_msg2: .asciz " es "
neg_msg:     .asciz "El factorial no esta definido para numeros negativos.\n"
newline:     .asciz "\n"
buffer:      .space 16
number:      .quad 0

.text
.global _start

_start:
    // Mostrar prompt
    mov x0, #1                 // fd = 1 (stdout)
    ldr x1, =prompt            // buffer = prompt
    mov x2, #46                // count = longitud del prompt
    mov x8, #64                // syscall = write
    svc #0                     // llamada al sistema

    // Leer la entrada
    mov x0, #0                 // fd = 0 (stdin)
    ldr x1, =buffer            // buffer para entrada
    mov x2, #16                // tamaño máximo
    mov x8, #63                // syscall = read
    svc #0                     // llamada al sistema

    // Procesar entrada (convertir ASCII a entero)
    mov x19, #0                // Inicializar valor
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
    // Almacenar número
    ldr x0, =number
    str x2, [x0]
    mov x19, x2               // Guardar número en x19
    
    // Verificar si el número es negativo
    cmp x19, #0
    blt negative_number
    
    // Inicializar factorial en 1
    mov x20, #1               // x20 será el resultado del factorial
    
    // Si el número es 0, el factorial es 1, imprimir resultado
    cmp x19, #0
    beq print_result
    
    // Calcular factorial para números > 0
    mov x21, #1               // Inicializar contador

factorial_loop:
    cmp x21, x19              // Comparar contador con número
    bgt print_result          // Si contador > número, imprimir resultado
    
    mul x20, x20, x21         // factorial *= contador
    add x21, x21, #1          // Incrementar contador
    b factorial_loop

negative_number:
    // Mensaje para números negativos
    mov x0, #1                // fd = 1 (stdout)
    ldr x1, =neg_msg          // buffer = mensaje
    mov x2, #56               // longitud del mensaje
    mov x8, #64               // syscall = write
    svc #0                    // llamada al sistema
    b exit_program

print_result:
    // Imprimir primera parte del mensaje
    mov x0, #1                // fd = 1 (stdout)
    ldr x1, =result_msg1      // "El factorial de "
    mov x2, #15               // longitud
    mov x8, #64               // syscall = write
    svc #0                    // llamada al sistema
    
    // Imprimir el número original
    // Esta es una versión simplificada que solo maneja dígitos individuales
    add x3, x19, #48          // Convertir a ASCII
    mov x0, #1                // fd = 1
    mov x1, sp                // Usar stack temporalmente
    strb w3, [x1]             // Guardar byte
    mov x2, #1                // Un byte
    mov x8, #64               // syscall = write
    svc #0                    // llamada al sistema
    
    // Imprimir segunda parte del mensaje
    mov x0, #1                // fd = 1 (stdout)
    ldr x1, =result_msg2      // " es "
    mov x2, #4                // longitud
    mov x8, #64               // syscall = write
    svc #0                    // llamada al sistema
    
    // Imprimir el resultado del factorial
    // Versión simplificada para números pequeños
    add x3, x20, #48          // Convertir a ASCII
    mov x0, #1                // fd = 1
    mov x1, sp                // Usar stack
    strb w3, [x1]             // Guardar byte
    mov x2, #1                // Un byte
    mov x8, #64               // syscall = write
    svc #0                    // llamada al sistema
    
    // Imprimir nueva línea
    mov x0, #1                // fd = 1
    ldr x1, =newline          // "\n"
    mov x2, #1                // longitud
    mov x8, #64               // syscall = write
    svc #0                    // llamada al sistema

exit_program:
    // Terminar programa
    mov x0, #0                // código de salida
    mov x8, #93               // syscall = exit
    svc #0
