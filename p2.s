# =========================================
# Grabacion asccinema: https://asciinema.org/a/p4GY3cwpQyxttiPgQ02dPyybm
# Programa: Inversión de cadena
# Autor: Perez Garcia Cesar Michael
# Descripción: Solicita una cadena al usuario, la invierte y muestra el resultado en consola
# =========================================

.section .data
prompt:           .asciz "Ingrese una cadena para invertir: "
mensaje_resultado: .asciz "Cadena invertida: "
newline:          .asciz "\n"
buffer:           .space 128          // Espacio para almacenar la entrada del usuario
output_buffer:    .space 128          // Buffer para la salida

.section .text
.global _start

_start:
    // Mostrar el mensaje de solicitud de cadena
    mov x0, #1                    // File descriptor 1 (salida estándar)
    ldr x1, =prompt               // Dirección del mensaje
    mov x2, #32                   // Longitud del prompt
    mov x8, #64                   // Syscall de write
    svc 0

    // Leer la cadena ingresada
    mov x0, #0                    // File descriptor 0 (entrada estándar)
    ldr x1, =buffer               // Guardar en buffer
    mov x2, #127                  // Tamaño máximo de entrada
    mov x8, #63                   // Syscall de read
    svc 0
    
    // Guardar longitud de la cadena leída
    mov x10, x0                   // x0 contiene bytes leídos

    // Calcular la longitud efectiva (sin el salto de línea)
    ldr x1, =buffer               // Dirección de la cadena en buffer
    bl remove_newline             // Eliminar salto de línea y obtener longitud real
    mov x9, x0                    // Guardar longitud efectiva en x9

    // Invertir la cadena
    ldr x1, =buffer               // Dirección de la cadena en buffer
    mov x2, x9                    // Usar longitud efectiva
    bl reverse_string             // Invertir la cadena

    // Mostrar el mensaje de resultado
    mov x0, #1                    // File descriptor 1 (salida estándar)
    ldr x1, =mensaje_resultado    // Dirección del mensaje
    mov x2, #18                   // Longitud del mensaje
    mov x8, #64                   // Syscall de write
    svc 0

    // Imprimir la cadena invertida
    mov x0, #1                    // File descriptor 1 (salida estándar)
    ldr x1, =buffer               // Dirección de la cadena invertida
    mov x2, x9                    // Longitud de la cadena
    mov x8, #64                   // Syscall de write
    svc 0

    // Imprimir nueva línea
    mov x0, #1                    // File descriptor 1
    ldr x1, =newline              // Dirección del salto de línea
    mov x2, #1                    // Longitud 1
    mov x8, #64                   // Syscall write
    svc 0

    // Terminar el programa
    mov x0, #0                    // Código de salida exitoso
    mov x8, #93                   // Syscall para "exit"
    svc 0

// =========================================
// Subrutina: remove_newline (Elimina salto de línea si existe y calcula longitud útil)
// =========================================
remove_newline:
    mov x0, #0                    // Inicializar longitud en 0
    
remove_loop:
    ldrb w2, [x1, x0]             // Leer el siguiente byte de la cadena
    cbz w2, end_remove            // Si es NULL (fin de cadena), termina
    cmp w2, #10                   // Comprobar si es salto de línea (LF)
    beq found_newline             // Si es salto de línea, reemplazarlo
    cmp w2, #13                   // Comprobar si es retorno de carro (CR)
    beq found_newline             // Si es retorno de carro, reemplazarlo
    add x0, x0, #1                // Incrementar longitud
    b remove_loop

found_newline:
    mov w3, #0                    // Carácter NULL
    strb w3, [x1, x0]             // Reemplazar salto con NULL
    b end_remove                  // Terminar la función

end_remove:
    ret                           // Retornar longitud en x0

// =========================================
// Subrutina: string_length (Calcula la longitud de la cadena en x1, retorna en x0)
// =========================================
string_length:
    mov x0, #0                    // Inicializar longitud en 0
    
length_loop:
    ldrb w2, [x1, x0]             // Leer el siguiente byte de la cadena
    cbz w2, end_length            // Si es NULL (fin de cadena), termina
    add x0, x0, #1                // Incrementar longitud
    b length_loop
    
end_length:
    ret                           // Retornar longitud en x0

// =========================================
// Subrutina: reverse_string (Invierte la cadena en x1 de longitud x2)
// =========================================
reverse_string:
    mov x3, #0                    // Índice inicial (comienzo de la cadena)
    sub x2, x2, #1                // Ajustar longitud para índices (último índice)
    
reverse_loop:
    cmp x3, x2                    // Comparar índices de inicio y fin
    b.ge end_reverse              // Si se encuentran o cruzan, termina
    
    // Intercambiar caracteres en buffer[x3] y buffer[x2]
    ldrb w4, [x1, x3]             // Cargar carácter en posición x3
    ldrb w5, [x1, x2]             // Cargar carácter en posición x2
    strb w5, [x1, x3]             // Almacenar carácter de x2 en x3
    strb w4, [x1, x2]             // Almacenar carácter de x3 en x2
    
    // Avanzar índices
    add x3, x3, #1                // Incrementar índice de inicio
    sub x2, x2, #1                // Decrementar índice de fin
    b reverse_loop
    
end_reverse:
    ret
