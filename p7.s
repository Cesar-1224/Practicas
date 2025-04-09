/*

# =========================================
# Programa: Búsqueda binaria de un número en un arreglo
# Autor: cesar perez  garcia.
# Descripción: Busca el número 8 en un arreglo predefinido y muestra el resultado en consola
# Programa en Python y Ensamblador
# =========================================

# Arreglo predefinido (debe estar ordenado para la búsqueda binaria)
arreglo = [1, 3, 5, 8, 13, 21, 34, 55, 89]

# Valor a buscar
numero_a_buscar = 8

# Búsqueda binaria
def busqueda_binaria(arreglo, numero):
    inicio = 0
    fin = len(arreglo) - 1
    
    while inicio <= fin:
        medio = (inicio + fin) // 2
        if arreglo[medio] == numero:
            return medio
        elif arreglo[medio] < numero:
            inicio = medio + 1
        else:
            fin = medio - 1
    
    return -1

# Llamada a la función de búsqueda
indice_encontrado = busqueda_binaria(arreglo, numero_a_buscar)

# Imprimir resultado
if indice_encontrado != -1:
    print(f"Número {numero_a_buscar} encontrado en la posición: {indice_encontrado}")
else:
    print(f"Número {numero_a_buscar} no encontrado en el arreglo")









Ensamblador
*/
        .section .data
arreglo:         .quad 1, 3, 5, 8, 13, 21, 34, 55, 89   // Arreglo ordenado de enteros
tam_arreglo:     .quad 9                               // Tamaño del arreglo
mensaje_encontrado: .asciz "Número 8 encontrado en la posición: "
mensaje_no_encontrado: .asciz "Número 8 no encontrado\n"
buffer:          .space 16                             // Espacio para almacenar el resultado

        .section .text
        .global _start

_start:
        // Inicializar los límites de la búsqueda
        ldr x0, =arreglo                              // Dirección del arreglo
        ldr x1, =tam_arreglo                          // Dirección del tamaño del arreglo
        ldr x1, [x1]                                  // Cargar el tamaño en x1 (fin)
        sub x1, x1, #1                                // Ajustar a índice máximo (fin)
        mov x2, #0                                    // Inicio del subarreglo (inicio)
        mov x3, #8                                    // Número a buscar

buscar_loop:
        cmp x2, x1                                    // Verificar si inicio > fin
        b.gt no_encontrado                           // Si es cierto, no se encontró el número

        // Calcular la posición media: medio = (inicio + fin) / 2
        add x4, x2, x1                                // inicio + fin
        lsr x4, x4, #1                                // Dividir por 2 (desplazamiento lógico)

        // Comparar el elemento en la posición media con el número buscado
        ldr x5, [x0, x4, LSL #3]                      // Cargar arreglo[medio] (elemento actual)
        cmp x5, x3                                    // Comparar con el número buscado
        beq encontrado                               // Si es igual, ir a "encontrado"
        b.lt ajustar_inicio                          // Si el medio es menor, ajustar inicio

        // Ajustar fin: fin = medio - 1
        sub x1, x4, #1
        b buscar_loop

ajustar_inicio:
        // Ajustar inicio: inicio = medio + 1
        add x2, x4, #1
        b buscar_loop

encontrado:
        ldr x0, =mensaje_encontrado                  // Mensaje de éxito
        bl print_str
        mov x0, x4                                   // Pasar índice encontrado a x0
        bl int_to_str                                // Convertir índice a texto
        ldr x0, =buffer                              // Dirección del buffer con el número convertido
        bl print_str                                 // Imprimir índice
        b fin_programa

no_encontrado:
        ldr x0, =mensaje_no_encontrado               // Mensaje de fracaso
        bl print_str

fin_programa:
        mov x8, #93                                  // Syscall para "exit"
        svc 0

// =========================================
// Subrutina: int_to_str (Convierte entero en x1 a cadena en x2)
// =========================================
int_to_str:
        mov x3, #10                                  // Divisor para conversión a decimal
        mov x4, x2                                   // Dirección de escritura en buffer

conv_loop:
        udiv x5, x1, x3                              // División entera x1 / 10
        msub x6, x5, x3, x1                          // Resto: x6 = x1 - (x5 * 10)
        add x6, x6, #'0'                             // Convertir dígito a carácter ASCII
        strb w6, [x4], #1                            // Guardar el dígito en el buffer
        mov x1, x5                                   // Actualizar x1 con el cociente
        cbnz x1, conv_loop                           // Repetir si x1 no es cero
        ret

// =========================================
// Subrutina: print_str (Imprime una cadena terminada en NULL en x0)
// =========================================
print_str:
        mov x8, #64                                  // Syscall para write
        mov x1, x0                                   // Dirección de la cadena a imprimir
        mov x2, #25                                  // Longitud máxima del mensaje
        mov x0, #1                                   // File descriptor 1 (salida estándar)
        svc 0
        ret
