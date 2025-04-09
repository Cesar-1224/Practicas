/*


# =========================================
# Programa: Verificación de palíndromo
# Autor: cesar michael perez garcia.
# Descripción: Solicita una cadena al usuario, verifica si es un palíndromo, y muestra el resultado
# Codigo en python y en Ensamblador
# =========================================

def print_str(message):
    """Imprime un mensaje en la consola."""
    print(message, end='')

def string_length(cadena):
    """Calcula la longitud de una cadena."""
    length = 0
    for char in cadena:
        if char == '\0':  # Simula el fin de cadena (NULL)
            break
        length += 1
    return length

def is_palindrome(cadena):
    """Verifica si una cadena es un palíndromo.
       Retorna True si es palíndromo, False si no lo es."""
    start_index = 0
    end_index = len(cadena) - 1

    while start_index < end_index:
        if cadena[start_index] != cadena[end_index]:
            return False  # No es palíndromo si los caracteres no coinciden
        start_index += 1
        end_index -= 1
    return True

# Programa principal
if __name__ == "__main__":
    # Mensajes iniciales
    prompt = "Ingrese una cadena para verificar si es palíndromo: "
    mensaje_palindromo = "La cadena es un palíndromo.\n"
    mensaje_no_palindromo = "La cadena no es un palíndromo.\n"

    # Solicita la cadena al usuario
    print_str(prompt)
    user_input = input().strip()  # Leer y limpiar entrada del usuario

    # Calcular la longitud de la cadena (opcional en Python)
    longitud = string_length(user_input)

    # Verificar si la cadena es un palíndromo
    if is_palindrome(user_input):
        print_str(mensaje_palindromo)
    else:
        print_str(mensaje_no_palindromo)









Ensamblador
*/


 .section .data
prompt:              .asciz "Ingrese una cadena para verificar si es palíndromo: "
mensaje_palindromo:  .asciz "La cadena es un palíndromo.\n"
mensaje_no_palindromo: .asciz "La cadena no es un palíndromo.\n"
buffer:             .space 128                  // Espacio para almacenar la entrada del usuario

        .section .text
        .global _start

_start:
        // Mostrar el mensaje de solicitud de cadena
        ldr x0, =prompt
        bl print_str

        // Leer la cadena ingresada
        mov x0, #0                    // File descriptor 0 (entrada estándar)
        ldr x1, =buffer               // Guardar en buffer
        mov x2, #127                  // Tamaño máximo de entrada (ajustado)
        mov x8, #63                   // Syscall de read
        svc 0

        // Calcular la longitud de la cadena
        ldr x1, =buffer               // Dirección de la cadena en buffer
        bl string_length              // Longitud de la cadena se almacena en x0

        // Verificar si la cadena es un palíndromo
        mov x2, x0                    // Guardar longitud en x2
        ldr x1, =buffer               // Dirección de la cadena en buffer
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
        mov x8, #93                   // Syscall para "exit"
        svc 0

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

// =========================================
// Subrutina: print_str (Imprime una cadena terminada en NULL en x0)
// =========================================
print_str:
        mov x8, #64                   // Syscall para write
        mov x1, x0                    // Dirección de la cadena a imprimir
        mov x2, #128                  // Longitud máxima del mensaje
        mov x0, #1                    // File descriptor 1 (salida estándar)
        svc 0
        ret
