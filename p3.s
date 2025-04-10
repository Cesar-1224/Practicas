# =========================================
# Programa: Verificación de palíndromo
# Autor: Perez Garcia Cesar Michael
# Descripción: Solicita una cadena al usuario, verifica si es un palíndromo, y muestra el resultado
# =========================================

.section .data
prompt:               .asciz "Ingrese una cadena para verificar si es palíndromo: "
mensaje_palindromo:   .asciz "La cadena es un palíndromo.\n"
mensaje_no_palindromo: .asciz "La cadena no es un palíndromo.\n"
buffer:               .space 128      // Espacio para almacenar la entrada del usuario
newline:              .byte 10       // Carácter de nueva línea

.section .text
.global _start

_start:
    // Mostrar el mensaje de solicitud de cadena
    ldr x0, =prompt
    bl print_str

    // Leer la cadena ingresada
    mov x0, #0                     // File descriptor 0 (entrada estándar)
    ldr x1, =buffer                // Guardar en buffer
    mov x2, #127                   // Tamaño máximo de entrada (ajustado)
    mov x8, #63                    // Syscall de read
    svc 0

    // x0 ahora contiene el número de bytes leídos
    mov x3, x0                     // Guardar longitud en x3
    
    // Eliminar el carácter de nueva línea si existe
    sub x4, x3, #1                // Índice del último carácter
    ldr x5, =buffer
    ldrb w6, [x5, x4]             // Cargar último carácter
    cmp w6, #10                   // Comprobar si es salto de línea
    bne skip_newline
    sub x3, x3, #1                // Reducir longitud si hay nueva línea
    
skip_newline:
    // Verificar si la cadena es un palíndromo
    ldr x1, =buffer               // Dirección de la cadena en buffer
    mov x2, x3                    // Pasar longitud ajustada
    bl is_palindrome              // Llamada a subrutina para verificar palíndromo (resultado en x0)

    // Mostrar el mensaje de resultado
    cmp x0, #1                    // Verificar si el resultado indica palíndromo
    beq es_palindromo_mensaje     // Si es palíndromo, saltar a mensaje de palíndromo
    b no_palindromo_mensaje       // Si no es palíndromo, saltar a mensaje de no palíndromo

es_palindromo_mensaje:
    ldr x0, =mensaje_palindromo
    bl print_str
    b fin                         // Saltar al final del programa

no_palindromo_mensaje:
    ldr x0, =mensaje_no_palindromo
    bl print_str
    b fin                         // Saltar al final del programa

fin:
    // Terminar el programa
    mov x0, #0                    // Código de salida 0 (éxito)
    mov x8, #93                   // Syscall para "exit"
    svc 0

// =========================================
// Subrutina: print_str (Imprime una cadena terminada en NULL en x0)
// =========================================
print_str:
    // Guardar registros que vamos a usar
    str x30, [sp, #-16]!      // Guardar dirección de retorno
    str x1, [sp, #-16]!       // Guardar x1
    str x2, [sp, #-16]!       // Guardar x2
    str x8, [sp, #-16]!       // Guardar x8
    
    mov x1, x0                // Dirección de la cadena a imprimir
    mov x2, #0                // Contador para longitud
    
str_len_loop:
    ldrb w3, [x1, x2]         // Cargar byte en posición x2
    cbz w3, end_str_len       // Si es 0 (fin de cadena), terminar
    add x2, x2, #1            // Incrementar contador
    b str_len_loop
    
end_str_len:
    mov x8, #64               // Syscall para write
    mov x0, #1                // File descriptor 1 (salida estándar)
    svc 0
    
    // Restaurar registros
    ldr x8, [sp], #16         // Recuperar x8
    ldr x2, [sp], #16         // Recuperar x2
    ldr x1, [sp], #16         // Recuperar x1
    ldr x30, [sp], #16        // Recuperar dirección de retorno
    ret

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
    ret

// =========================================
// Subrutina: is_palindrome (Verifica si la cadena en x1 de longitud x2 es palíndromo, retorna 1 si lo es, 0 si no)
// =========================================
is_palindrome:
    // Si la cadena está vacía o tiene un solo caracter, es palíndromo
    cmp x2, #1
    b.le palindrome_true
    
    sub x2, x2, #1                // Ajustar longitud para índices (último índice)
    mov x3, #0                    // Índice inicial (comienzo de la cadena)

palindrome_loop:
    cmp x3, x2                    // Comparar índices de inicio y fin
    b.ge palindrome_true          // Si se encuentran o cruzan, es palíndromo
    
    // Comparar caracteres en buffer[x3] y buffer[x2]
    ldrb w4, [x1, x3]             // Cargar carácter en posición x3
    ldrb w5, [x1, x2]             // Cargar carácter en posición x2
    cmp w4, w5                    // Comparar los caracteres
    b.ne palindrome_false         // Si son diferentes, no es palíndromo
    
    // Avanzar índices
    add x3, x3, #1
    sub x2, x2, #1
    b palindrome_loop

palindrome_true:
    mov x0, #1                    // Indicar que es palíndromo
    ret

palindrome_false:
    mov x0, #0                    // Indicar que no es palíndromo
    ret
