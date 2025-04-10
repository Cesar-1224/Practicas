/*
# =========================================
# Programa: Suma de dos numeros con entrada
# Autor: Perez Garcia Cesar Michael
# Descripcion: Solicita dos numeros al usuario, los suma y muestra el resultado en consola
# =========================================
*/

        .section .data
prompt1: .asciz "Ingrese el primer numero: "
prompt2: .asciz "Ingrese el segundo numero: "
resultado: .asciz "Resultado de la suma: "
buffer:   .space 16                 // Espacio para almacenar la entrada del usuario
buffer_resultado: .space 16         // Buffer separado para el resultado
nuevalinea: .asciz "\n"

        .section .text
        .global _start

_start:
        // Mostrar mensaje para el primer número
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =prompt1            // Mensaje a imprimir
        mov x2, #25                 // Longitud del mensaje
        mov x8, #64                 // Syscall para write
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
        mov x19, x0                 // Guardar primer número en x19

        // Mostrar mensaje para el segundo número
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =prompt2            // Mensaje a imprimir
        mov x2, #26                 // Longitud del mensaje
        mov x8, #64                 // Syscall para write
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
        add x0, x19, x0             // Sumar primer número (x19) y segundo número (x0)

        // Convertir el resultado a texto usando buffer_resultado
        bl int_to_str               // Convertir número a texto

        // Imprimir el texto del resultado
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =resultado          // Mensaje de "Resultado de la suma: "
        mov x2, #22                 // Longitud del mensaje
        mov x8, #64                 // Syscall para write
        svc 0

        // Imprimir el valor convertido
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =buffer_resultado   // Dirección del buffer que contiene el número
        
        // Calcular longitud de la cadena para imprimir exactamente lo necesario
        mov x2, #0                  // Contador de longitud
longitud_loop:
        ldrb w3, [x1, x2]           // Cargar carácter en posición x2
        cbz w3, longitud_fin        // Si es 0, terminar
        add x2, x2, #1              // Incrementar contador
        b longitud_loop
longitud_fin:
        
        // Ahora x2 contiene la longitud exacta del resultado
        mov x8, #64                 // Syscall para write
        svc 0

        // Imprimir nueva línea
        mov x0, #1                  // File descriptor 1 (salida estándar)
        ldr x1, =nuevalinea         // Dirección de la nueva línea
        mov x2, #1                  // Longitud de la nueva línea
        mov x8, #64                 // Syscall para write
        svc 0

        // Terminar el programa
        mov x8, #93                 // Syscall para "exit"
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
        cmp w3, #0                  // Verificar si es fin de cadena (NULL)
        beq str_to_int_end          // Si es NULL, terminar
        sub w3, w3, #'0'            // Convertir ASCII a valor numérico
        mul x0, x0, x2              // Multiplicar resultado actual por 10
        add x0, x0, x3              // Añadir el dígito actual
        b str_to_int_loop           // Repetir para siguiente carácter

str_to_int_end:
        ret

// =========================================
// Subrutina: int_to_str (Convierte entero en x0 a cadena en buffer_resultado)
// =========================================
int_to_str:
        // Guardar x0 en x1 para la conversión
        mov x1, x0
        
        // Limpiar el buffer_resultado
        ldr x2, =buffer_resultado
        mov x3, #0
        str x3, [x2], #8            // Limpiar los primeros 8 bytes
        str x3, [x2]                // Limpiar los siguientes 8 bytes
        
        // Preparar buffer_resultado para la conversión
        ldr x2, =buffer_resultado
        mov x4, #0                  // Contador de dígitos
        
        // Si el número es 0, manejar caso especial
        cmp x1, #0
        bne int_to_str_loop
        mov w3, #'0'                // Carácter '0'
        strb w3, [x2], #1           // Guardar '0' y avanzar
        mov w3, #0                  // Terminador NULL
        strb w3, [x2]               // Añadir terminador
        ret

int_to_str_loop:
        // Verificar si ya terminamos
        cmp x1, #0
        beq int_to_str_reverse
        
        // Obtener último dígito: x1 % 10
        mov x5, #10
        udiv x6, x1, x5             // x6 = x1 / 10
        msub x7, x6, x5, x1         // x7 = x1 - (x6 * 10) = x1 % 10
        
        // Guardar dígito temporalmente en la pila
        sub sp, sp, #16             // Hacer espacio en la pila
        str x7, [sp]                // Guardar dígito
        
        // Actualizar contador y x1
        add x4, x4, #1              // Incrementar contador
        mov x1, x6                  // x1 = x1 / 10
        b int_to_str_loop

int_to_str_reverse:
        // Ahora recuperamos dígitos en orden inverso
        mov x5, x4                  // Copiar contador
        ldr x2, =buffer_resultado   // Reiniciar puntero al buffer
int_to_str_pop:
        cmp x5, #0
        beq int_to_str_end
        
        // Recuperar dígito de la pila
        ldr x7, [sp]                // Cargar dígito
        add sp, sp, #16             // Liberar espacio de pila
        
        // Convertir a ASCII y guardar
        add w7, w7, #'0'            // Convertir a carácter ASCII
        strb w7, [x2], #1           // Guardar en buffer y avanzar
        
        sub x5, x5, #1              // Decrementar contador
        b int_to_str_pop

int_to_str_end:
        // Añadir terminador NULL
        mov w7, #0
        strb w7, [x2]
        ret
