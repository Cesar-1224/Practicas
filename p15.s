/*
Programa: Conversión de entero a ASCII
Autor: Perez Garcia Cesar Michael
Descripción: Conversión de un número entero a su representación en cadena ASCII.
*/

    .global _start     // Punto de entrada para el enlazador
    .extern printf     // Declaramos printf para que se resuelva en libc
    .extern exit       // Declaramos exit para terminar el programa

    .data
        // Número entero a convertir
        number:      .quad   12345

        // Cadena donde se almacenará el resultado ASCII (máximo 20 caracteres)
        ascii_str:   .space  20
        newline:     .string "\n"

        // Mensajes para imprimir
        msg:         .string "Número convertido a ASCII: "
        format:      .string "%s"

    .text
// Etiqueta _start: punto de entrada del programa
_start:
    bl main         // Llamar a main
    // Al regresar, el valor de retorno de main está en x0; se pasa a exit.
    bl exit         // Termina el programa

// La función main se declara global (opcional, pero ayuda a la legibilidad)
    .global main
    .align 2

main:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Preparar parámetros para la conversión de entero a ASCII
    ldr     x0, =number               // Cargar dirección del número a convertir
    ldr     x0, [x0]                  // Cargar el valor del número
    adrp    x1, ascii_str             // Dirección base para el resultado ASCII
    add     x1, x1, :lo12:ascii_str
    bl      int_to_ascii

    // Imprimir mensaje de resultado
    adrp    x0, msg
    add     x0, x0, :lo12:msg
    bl      printf

    // Imprimir la cadena ASCII resultante
    adrp    x0, ascii_str
    add     x0, x0, :lo12:ascii_str
    adrp    x1, format
    add     x1, x1, :lo12:format
    bl      printf

    // Imprimir nueva línea
    adrp    x0, newline
    add     x0, x0, :lo12:newline
    bl      printf

    // Restaurar stack y salir
    ldp     x29, x30, [sp], #16
    mov     x0, #0    // Código de salida 0
    ret

// Función: int_to_ascii
// Conversión de un entero a su representación ASCII.
// Entrada:  x0 = número a convertir
//           x1 = dirección donde se guardará la cadena (se llena al revés y luego se invierte)
int_to_ascii:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Puntero al final de la cadena de destino
    mov     x2, x1

    // Cargar el valor 10 en x5 para usarlo en divisiones y restos
    mov     x5, #10

    // Comprobar si el número es cero
    cmp     x0, #0
    b.eq    zero_case

convert_loop:
    // Obtener el dígito menos significativo
    udiv    x3, x0, x5               // División: x0 / 10, resultado en x3
    msub    x4, x3, x5, x0           // Resto: x4 = x0 - (x3 * 10)
    add     x4, x4, #'0'             // Convertir a carácter ASCII
    strb    w4, [x2, #-1]!           // Almacenar el carácter y mover el puntero

    // Actualizar el número para obtener el siguiente dígito
    mov     x0, x3
    cbnz    x0, convert_loop         // Repetir si x0 no es cero

    b       end_conversion

zero_case:
    // Si el número es cero, escribir '0'
    mov     w4, #'0'
    strb    w4, [x2, #-1]

end_conversion:
    // Invertir la cadena en su lugar
    mov     x3, x2                    // Puntero a inicio de la cadena invertida
    sub     x1, x1, x2                // Calcular la longitud de la cadena (diferencia de punteros)
    add     x1, x1, x3                // x1 apunta al último carácter

reverse_loop:
    cmp     x3, x1
    b.ge    done_reversing
    ldrb    w4, [x3]
    ldrb    w5, [x1]
    strb    w5, [x3]
    strb    w4, [x1]
    add     x3, x3, #1
    sub     x1, x1, #1
    b       reverse_loop

done_reversing:
    ldp     x29, x30, [sp], #16
    ret
