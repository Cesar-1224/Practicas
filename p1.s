# =========================================
# Programa: Conversión de Celsius a Fahrenheit
# Autor: Perez Garcia Cesar Michael
# Descripción: Solicita una temperatura en grados Celsius, la convierte a Fahrenheit y muestra el resultado
# =========================================

.section .data
prompt:            .asciz "Ingrese la temperatura en grados Celsius: "
mensaje_resultado: .asciz "Temperatura en Fahrenheit: "
newline:           .asciz "\n"
buffer:            .space 16          // Espacio para almacenar la entrada del usuario
output_buffer:     .space 16          // Buffer para la salida

.section .text
.global _start

_start:
    // Mostrar el mensaje de solicitud de temperatura en Celsius
    mov x0, #1                    // File descriptor 1 (salida estándar)
    ldr x1, =prompt               // Dirección del mensaje
    mov x2, #40                   // Longitud del mensaje
    mov x8, #64                   // Syscall de write
    svc 0

    // Leer la temperatura ingresada
    mov x0, #0                    // File descriptor 0 (entrada estándar)
    ldr x1, =buffer               // Guardar en buffer
    mov x2, #15                   // Tamaño máximo de entrada
    mov x8, #63                   // Syscall de read
    svc 0
    
    // Guardar la longitud leída
    mov x10, x0                   // x0 contiene la cantidad de bytes leídos

    // Convertir la entrada de Celsius a entero
    ldr x1, =buffer               // Dirección del buffer con el número en texto
    bl str_to_int                 // Llamada a subrutina para convertir a entero en x0

    // Guardar Celsius en x9 para la conversión
    mov x9, x0                    

    // Convertir de Celsius a Fahrenheit
    bl celsius_to_fahrenheit      // Llamada a la subrutina (resultado en x0)
    
    // Guardar el resultado Fahrenheit en x19
    mov x19, x0

    // Mostrar el mensaje de resultado
    mov x0, #1                    // File descriptor 1 (salida estándar)
    ldr x1, =mensaje_resultado    // Dirección del mensaje
    mov x2, #25                   // Longitud aproximada del mensaje
    mov x8, #64                   // Syscall de write
    svc 0

    // Convertir el resultado de Fahrenheit a cadena para mostrar
    mov x0, x19                   // Cargar el valor Fahrenheit que guardamos
    ldr x2, =output_buffer        // Dirección del buffer para el resultado en texto
    bl int_to_str                 // Convertir el número en x0 a texto en x2, con puntero al resultado en x0

    // x0 ahora contiene la dirección del primer dígito de la representación de texto
    mov x1, x0                    // Direccion de la cadena resultado
    
    // Calcular la longitud de la cadena resultado
    mov x11, #0                   // Contador de longitud
count_loop:
    ldrb w12, [x1, x11]
    cbz w12, end_count
    add x11, x11, #1
    b count_loop
end_count:

    // Imprimir la temperatura en Fahrenheit
    mov x0, #1                    // File descriptor 1 (salida estándar)
    // x1 ya tiene la dirección de la cadena a imprimir
    mov x2, x11                   // Longitud del resultado
    mov x8, #64                   // Syscall de write
    svc 0

    // Imprimir nueva línea
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc 0

    // Terminar el programa
    mov x0, #0                    // Código de salida exitoso
    mov x8, #93                   // Syscall para "exit"
    svc 0

// =========================================
// Subrutina: celsius_to_fahrenheit (Convierte x9 de Celsius a Fahrenheit, resultado en x0)
// =========================================
celsius_to_fahrenheit:
    mov x0, x9                    // Cargar el valor Celsius de x9
    mov x1, #9                    // Multiplicador para Celsius (C * 9)
    mul x0, x0, x1                // x0 = Celsius * 9
    mov x1, #5
    udiv x0, x0, x1               // x0 = (Celsius * 9) / 5
    add x0, x0, #32               // x0 = x0 + 32 (Fahrenheit)
    ret

// =========================================
// Subrutina: str_to_int (Convierte cadena en x1 a entero en x0)
// =========================================
str_to_int:
    mov x0, #0                    // Inicializa el resultado en 0
    mov x2, #10                   // Base decimal

convert_loop:
    ldrb w3, [x1], #1             // Leer siguiente byte de la cadena
    cmp w3, #10                   // Verificar salto de línea (ASCII 10)
    beq end_convert               // Si es salto de línea, termina conversión
    cmp w3, #13                   // Verificar retorno de carro (ASCII 13)
    beq end_convert               // Si es retorno de carro, termina conversión
    sub w3, w3, #'0'              // Convertir de ASCII a dígito
    cmp w3, #9                    // Verificar si es un dígito válido (0-9)
    bgt end_convert               // Si es mayor que 9, terminar
    mul x0, x0, x2                // Multiplica el resultado actual por 10
    add x0, x0, x3                // Sumar el dígito actual
    b convert_loop

end_convert:
    ret

// =========================================
// Subrutina: int_to_str (Convierte entero en x0 a cadena en x2)
// =========================================
int_to_str:
    mov x1, x0                    // Copiar valor entero a x1
    mov x4, x2                    // Guardar inicio del buffer
    add x4, x4, #15               // Ir al final del buffer
    mov w5, #0                    // Terminador nulo
    strb w5, [x4]                 // Colocar terminador nulo al final
    sub x4, x4, #1                // Mover puntero a la posición anterior

    mov x3, #10                   // Base decimal
    
    // Si el número es 0, manejar caso especial
    cmp x1, #0
    bne conv_loop_start
    mov w5, #'0'                  // Carácter '0'
    strb w5, [x4], #-1            // Guardar '0' y retroceder
    b reverse_string

conv_loop_start:
conv_loop:
    cmp x1, #0                    // Verificar si terminamos
    beq reverse_string            // Si es 0, terminar conversión
    udiv x5, x1, x3               // Dividir x1 por 10 (cociente en x5)
    msub x6, x5, x3, x1           // Obtener residuo (x6 = x1 % 10)
    add x6, x6, #'0'              // Convertir dígito a ASCII
    strb w6, [x4], #-1            // Guardar carácter en buffer y retroceder
    mov x1, x5                    // Actualizar x1 al cociente
    b conv_loop                   // Repetir

reverse_string:
    // x4 apunta al primer dígito, x2 es el inicio del buffer
    add x4, x4, #1                // Ajustar puntero al primer dígito real
    mov x0, x4                    // Retornar puntero al inicio de la cadena
    ret
