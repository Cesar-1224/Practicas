// ===============================================
// Estudiante y No de control: Perez Garcia Cesar Michael
// Descripcion: Programa en ensamblador ARM64 para verificar si un numero es primo
// Practica: p22
// ===============================================

.data
prompt:      .asciz "Introduce un numero: "
prime_msg:   .asciz "El numero es primo.\n"
not_prime_msg: .asciz "El numero no es primo.\n"
newline:     .asciz "\n"
buffer:      .space 16
num:         .quad 0

.text
.global _start

_start:
    // Mostrar prompt
    mov x0, #1                 // fd = 1 (stdout)
    ldr x1, =prompt            // buffer = prompt
    mov x2, #19                // count = longitud del prompt
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
    ldr x0, =num
    str x2, [x0]
    mov x19, x2                // Guardar número en x19

    // Comprobar si el número es menor que 2
    cmp x19, #2
    blt not_prime              // Si num < 2, no es primo

    // Si es 2, es primo
    cmp x19, #2
    beq is_prime

    // Comprobar si es par (excepto 2)
    mov x0, x19
    mov x1, #2
    udiv x2, x0, x1
    msub x3, x2, x1, x0        // x3 = x0 - (x2 * x1) = x19 % 2
    cmp x3, #0
    beq not_prime              // Si es divisible por 2, no es primo

    // Comenzar a verificar divisores impares desde 3
    mov x20, #3                // x20 será el divisor

check_loop:
    // Calcular x20 * x20
    mul x21, x20, x20
    cmp x21, x19
    bgt is_prime               // Si x20 * x20 > num, es primo

    // Verificar si num es divisible por x20
    mov x0, x19                // Mover num a x0
    mov x1, x20                // Mover divisor a x1
    udiv x2, x0, x1            // x2 = x0 / x1
    msub x3, x2, x1, x0        // x3 = x0 - (x2 * x1) = x19 % x20
    cmp x3, #0
    beq not_prime              // Si es divisible, no es primo

    // Incrementar divisor en 2 (solo comprobamos impares)
    add x20, x20, #2
    b check_loop

is_prime:
    // Mostrar mensaje de que es primo
    mov x0, #1                 // fd = 1 (stdout)
    ldr x1, =prime_msg         // buffer = mensaje
    mov x2, #18                // longitud del mensaje
    mov x8, #64                // syscall = write
    svc #0                     // llamada al sistema
    b exit_program

not_prime:
    // Mostrar mensaje de que no es primo
    mov x0, #1                 // fd = 1 (stdout)
    ldr x1, =not_prime_msg     // buffer = mensaje
    mov x2, #22                // longitud del mensaje
    mov x8, #64                // syscall = write
    svc #0                     // llamada al sistema

exit_program:
    // Terminar programa
    mov x0, #0                 // código de salida
    mov x8, #93                // syscall = exit
    svc #0
