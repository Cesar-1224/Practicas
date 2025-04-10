/*
# =========================================
# Programa: Suma de dos matrices 3x3 con entrada
# Autor: Perez Garcia Cesar Michael
# Descripcion: Solicita una matriz 3x3 al usuario, luego otra matriz 3x3, las suma y muestra el resultado.
# =========================================
*/

        .section .data
prompt_matrizA: .asciz "Ingrese los elementos de la matriz A (3x3):\n"
prompt_matrizB: .asciz "Ingrese los elementos de la matriz B (3x3):\n"
prompt_elemento: .asciz "Elemento [%d][%d]: "
resultado_text: .asciz "Resultado de la suma:\n"
espacio:        .asciz " "
nuevalinea:     .asciz "\n"
buffer:         .space 16            // Espacio para almacenar la entrada del usuario
matrizA:        .space 36            // 3x3 = 9 elementos de 4 bytes para la primera matriz
matrizB:        .space 36            // 3x3 = 9 elementos de 4 bytes para la segunda matriz
resultado:      .space 36            // 3x3 = 9 elementos de 4 bytes para la matriz de resultado

        .section .text
        .global _start

_start:
        // Mostrar mensaje para ingresar matriz A
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =prompt_matrizA     // Mensaje a imprimir
        mov x2, #38                 // Longitud del mensaje
        mov x8, #64                 // Syscall para write
        svc 0

        // Leer los elementos de matriz A
        mov w19, #0                 // Índice de fila i
matrizA_fila_loop:
        mov w20, #0                 // Índice de columna j
matrizA_columna_loop:
        // Calcular la posición exacta en matrizA (i*3 + j) * 4
        mov w21, w19                // w21 = i
        lsl w21, w21, #1            // w21 = i * 2
        add w21, w21, w19           // w21 = i * 3
        add w21, w21, w20           // w21 = i * 3 + j
        lsl w21, w21, #2            // w21 = (i * 3 + j) * 4

        // Mostrar prompt para elemento actual
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =prompt_elemento    // Mensaje a imprimir
        mov x2, #15                 // Longitud aproximada del mensaje
        mov x8, #64                 // Syscall para write
        svc 0

        // Leer entrada para el elemento
        mov x0, #0                  // File descriptor 0 (entrada estándar)
        ldr x1, =buffer             // Guardar en buffer
        mov x2, #15                 // Tamaño máximo de entrada
        mov x8, #63                 // Syscall de read
        svc 0

        // Convertir la entrada a entero
        ldr x1, =buffer
        bl str_to_int

        // Almacenar en matrizA
        ldr x2, =matrizA
        str w0, [x2, x21]           // matrizA[i][j] = valor convertido

        // Incrementar índice de columna y comprobar
        add w20, w20, #1
        cmp w20, #3
        blt matrizA_columna_loop    // Si j < 3, repetir columna

        // Incrementar índice de fila y comprobar
        add w19, w19, #1
        cmp w19, #3
        blt matrizA_fila_loop       // Si i < 3, repetir fila

        // Mostrar mensaje para ingresar matriz B
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =prompt_matrizB     // Mensaje a imprimir
        mov x2, #38                 // Longitud del mensaje
        mov x8, #64                 // Syscall para write
        svc 0

        // Leer los elementos de matriz B (mismo proceso que matrizA)
        mov w19, #0
matrizB_fila_loop:
        mov w20, #0
matrizB_columna_loop:
        // Calcular la posición exacta en matrizB (i*3 + j) * 4
        mov w21, w19                // w21 = i
        lsl w21, w21, #1            // w21 = i * 2
        add w21, w21, w19           // w21 = i * 3
        add w21, w21, w20           // w21 = i * 3 + j
        lsl w21, w21, #2            // w21 = (i * 3 + j) * 4

        // Mostrar prompt para elemento actual
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =prompt_elemento    // Mensaje a imprimir
        mov x2, #15                 // Longitud aproximada del mensaje
        mov x8, #64                 // Syscall para write
        svc 0

        // Leer entrada para el elemento
        mov x0, #0                  // File descriptor 0 (entrada estándar)
        ldr x1, =buffer             // Guardar en buffer
        mov x2, #15                 // Tamaño máximo de entrada
        mov x8, #63                 // Syscall de read
        svc 0

        // Convertir la entrada a entero
        ldr x1, =buffer
        bl str_to_int

        // Almacenar en matrizB
        ldr x2, =matrizB
        str w0, [x2, x21]           // matrizB[i][j] = valor convertido

        // Incrementar índice de columna y comprobar
        add w20, w20, #1
        cmp w20, #3
        blt matrizB_columna_loop    // Si j < 3, repetir columna

        // Incrementar índice de fila y comprobar
        add w19, w19, #1
        cmp w19, #3
        blt matrizB_fila_loop       // Si i < 3, repetir fila

        // Sumar las matrices y almacenar el resultado en "resultado"
        mov w19, #0                 // i = 0
suma_fila_loop:
        mov w20, #0                 // j = 0
suma_columna_loop:
        // Calcular la posición exacta (i*3 + j) * 4
        mov w21, w19                // w21 = i
        lsl w21, w21, #1            // w21 = i * 2
        add w21, w21, w19           // w21 = i * 3
        add w21, w21, w20           // w21 = i * 3 + j
        lsl w21, w21, #2            // w21 = (i * 3 + j) * 4

        // Cargar elementos
        ldr x5, =matrizA
        ldr w6, [x5, x21]           // w6 = matrizA[i][j]
        ldr x5, =matrizB
        ldr w7, [x5, x21]           // w7 = matrizB[i][j]
        
        // Sumar y guardar
        add w8, w6, w7              // w8 = matrizA[i][j] + matrizB[i][j]
        ldr x5, =resultado
        str w8, [x5, x21]           // resultado[i][j] = suma

        // Incrementar índice de columna y comprobar
        add w20, w20, #1
        cmp w20, #3
        blt suma_columna_loop

        // Incrementar índice de fila y comprobar
        add w19, w19, #1
        cmp w19, #3
        blt suma_fila_loop

        // Mostrar resultado de la suma de matrices
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =resultado_text     // Mensaje a imprimir
        mov x2, #20                 // Longitud del mensaje
        mov x8, #64                 // Syscall para write
        svc 0

        // Imprimir matriz resultado
        mov w19, #0                 // i = 0
print_fila_loop:
        mov w20, #0                 // j = 0
print_columna_loop:
        // Calcular la posición exacta (i*3 + j) * 4
        mov w21, w19                // w21 = i
        lsl w21, w21, #1            // w21 = i * 2
        add w21, w21, w19           // w21 = i * 3
        add w21, w21, w20           // w21 = i * 3 + j
        lsl w21, w21, #2            // w21 = (i * 3 + j) * 4

        // Cargar valor de resultado[i][j]
        ldr x5, =resultado
        ldr w0, [x5, x21]
        
        // Convertir a string
        bl int_to_str

        // Imprimir el valor
        mov x0, #1                  // File descriptor 1
        ldr x1, =buffer             // El número convertido
        mov x2, #10                 // Longitud max
        mov x8, #64                 // write syscall
        svc 0

        // Imprimir un espacio
        mov x0, #1
        ldr x1, =espacio
        mov x2, #1
        mov x8, #64
        svc 0

        // Incrementar j y comprobar
        add w20, w20, #1
        cmp w20, #3
        blt print_columna_loop

        // Imprimir nueva línea después de cada fila
        mov x0, #1
        ldr x1, =nuevalinea
        mov x2, #1
        mov x8, #64
        svc 0

        // Incrementar i y comprobar
        add w19, w19, #1
        cmp w19, #3
        blt print_fila_loop

        // Terminar programa
        mov x8, #93                 // Syscall para exit
        mov x0, #0                  // Código de salida 0
        svc 0

// =========================================
// Subrutina: str_to_int (Convierte cadena en x1 a entero en x0)
// =========================================
str_to_int:
        mov x0, #0                  // Inicializa el resultado en 0
        mov x2, #10                 // Base decimal

str_to_int_loop:
        ldrb w3, [x1], #1           // Cargar siguiente byte y avanzar
        cmp w3, #10                 // Verificar si es nueva línea (ASCII 10)
        beq str_to_int_end          // Si es nueva línea, terminar
        cmp w3, #13                 // Verificar si es retorno de carro (ASCII 13)
        beq str_to_int_end          // Si es retorno de carro, terminar
        sub w3, w3, #'0'            // Convertir ASCII a valor numérico
        mul x0, x0, x2              // Multiplicar resultado actual por 10
        add x0, x0, x3              // Añadir el dígito actual
        b str_to_int_loop           // Repetir para siguiente carácter

str_to_int_end:
        ret

// =========================================
// Subrutina: int_to_str (Convierte entero en w0 a cadena en buffer)
// =========================================
int_to_str:
        // Guardar x0 en x1 para la conversión
        mov x1, x0
        
        // Preparar espacio para los dígitos en orden inverso
        ldr x2, =buffer
        add x2, x2, #9              // Apuntar al final del buffer
        mov w3, #0                  // Terminador nulo
        strb w3, [x2], #-1          // Guardar terminador y retroceder

        // Si el número es 0, manejar caso especial
        cmp x1, #0
        bne int_to_str_loop
        mov w3, #'0'                // Carácter '0'
        strb w3, [x2], #-1          // Guardar '0' y retroceder
        b int_to_str_end

int_to_str_loop:
        // Verificar si ya terminamos
        cmp x1, #0
        beq int_to_str_end

        // Obtener último dígito: x1 % 10
        mov x4, #10
        udiv x5, x1, x4             // x5 = x1 / 10
        msub x6, x5, x4, x1         // x6 = x1 - (x5 * 10) = x1 % 10

        // Convertir a ASCII y guardar
        add w6, w6, #'0'            // Convertir a carácter ASCII
        strb w6, [x2], #-1          // Guardar carácter y retroceder

        // Actualizar x1 = x1 / 10
        mov x1, x5
        b int_to_str_loop

int_to_str_end:
        // Mover el puntero resultado al primer dígito
        add x2, x2, #1
        ldr x0, =buffer
        
        // Copiar desde la posición calculada al inicio del buffer
int_to_str_copy:
        ldrb w3, [x2]
        cbz w3, int_to_str_copy_end
        strb w3, [x0], #1
        add x2, x2, #1
        b int_to_str_copy

int_to_str_copy_end:
        mov w3, #0                  // Terminador nulo
        strb w3, [x0]
        ret
