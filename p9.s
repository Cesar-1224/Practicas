/*
# =========================================
# Programa: Búsqueda binaria de un número en un arreglo
# Autor: Perez Garcia Cesar Michael
# Descripción: Solicita al usuario un número y lo busca en un arreglo predefinido
# Programa en Python y Ensamblador
# =========================================

# Python
"""
# Arreglo predefinido (debe estar ordenado para la búsqueda binaria)
arreglo = [1, 3, 5, 8, 13, 21, 34, 55, 89]

# Solicitar valor a buscar
numero_a_buscar = int(input("Ingrese el número a buscar: "))

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
"""
*/
        .section .data
arreglo:         .quad 1, 3, 5, 8, 13, 21, 34, 55, 89   // Arreglo ordenado de enteros
tam_arreglo:     .quad 9                                // Tamaño del arreglo
prompt:          .asciz "Ingrese el número a buscar: "
mensaje_encontrado: .asciz "Número encontrado en la posición: "
mensaje_no_encontrado: .asciz "Número no encontrado en el arreglo\n"
buffer_entrada:  .space 16                              // Buffer para entrada del usuario
buffer_salida:   .space 16                              // Buffer para convertir números a texto
nueva_linea:     .asciz "\n"                            // Carácter nueva línea
numero_buscado:  .quad 0                                // Almacena el número a buscar

        .section .text
        .global _start

_start:
        // Mostrar prompt para pedir número al usuario
        ldr x0, =prompt
        bl print_str
        
        // Leer la entrada del usuario
        mov x0, #0                                   // File descriptor 0 (stdin)
        ldr x1, =buffer_entrada                      // Buffer para entrada
        mov x2, #15                                  // Máximo 15 caracteres
        mov x8, #63                                  // syscall read
        svc #0
        
        // Convertir la entrada a número
        ldr x0, =buffer_entrada
        bl str_to_int
        // x0 contiene ahora el número ingresado
        
        // Guardar el número a buscar
        ldr x1, =numero_buscado
        str x0, [x1]
        mov x3, x0                                   // x3 = número a buscar

        // Inicializar los límites de la búsqueda
        ldr x0, =arreglo                              // Dirección del arreglo
        ldr x1, =tam_arreglo                          // Dirección del tamaño del arreglo
        ldr x1, [x1]                                  // Cargar el tamaño en x1 (fin)
        sub x1, x1, #1                                // Ajustar a índice máximo (fin)
        mov x2, #0                                    // Inicio del subarreglo (inicio)

buscar_loop:
        cmp x2, x1                                    // Verificar si inicio > fin
        b.gt no_encontrado                            // Si es cierto, no se encontró el número

        // Calcular la posición media: medio = (inicio + fin) / 2
        add x4, x2, x1                                // inicio + fin
        lsr x4, x4, #1                                // Dividir por 2 (desplazamiento lógico)

        // Comparar el elemento en la posición media con el número buscado
        ldr x5, [x0, x4, LSL #3]                      // Cargar arreglo[medio] (elemento actual)
        cmp x5, x3                                    // Comparar con el número buscado
        beq encontrado                                // Si es igual, ir a "encontrado"
        b.lt ajustar_inicio                           // Si el medio es menor, ajustar inicio

        // Ajustar fin: fin = medio - 1
        sub x1, x4, #1
        b buscar_loop

ajustar_inicio:
        // Ajustar inicio: inicio = medio + 1
        add x2, x4, #1
        b buscar_loop

encontrado:
        // Mostrar mensaje de encontrado
        ldr x0, =mensaje_encontrado
        bl print_str
        
        // Convertir el índice encontrado a texto
        mov x1, x4                                    // Índice encontrado
        ldr x2, =buffer_salida                        // Buffer para salida
        bl int_to_str
        
        // Mostrar el índice encontrado
        ldr x0, =buffer_salida
        bl print_str
        
        // Mostrar nueva línea
        ldr x0, =nueva_linea
        bl print_str
        
        b fin_programa

no_encontrado:
        // Mostrar mensaje de no encontrado
        ldr x0, =mensaje_no_encontrado
        bl print_str

fin_programa:
        // Terminar el programa
        mov x8, #93                                   // syscall exit
        mov x0, #0                                    // Código de salida 0 (éxito)
        svc #0

// =========================================
// Subrutina: str_to_int (Convierte una cadena de entrada en un entero)
// Entrada: x0 = dirección de la cadena
// Salida: x0 = valor entero
// =========================================
str_to_int:
        // Guardar registros
        stp x19, x20, [sp, #-16]!                     // Preservar registros
        stp x21, x22, [sp, #-16]!
        
        mov x19, x0                                   // Puntero a la cadena
        mov x20, #0                                   // Valor acumulado
        mov x21, #10                                  // Base (decimal)
        
conv_loop:
        ldrb w22, [x19], #1                           // Cargar un byte y avanzar el puntero
        
        // Comprobar si es fin de línea o espacio en blanco
        cmp w22, #'\n'
        beq conv_done
        cmp w22, #0
        beq conv_done
        cmp w22, #' '
        beq conv_done
        
        // Convertir ASCII a valor numérico
        sub w22, w22, #'0'                            // ASCII '0' a valor 0
        
        // Verificar si es un dígito válido (0-9)
        cmp w22, #0
        b.lt conv_done                                // Si es menor que 0, terminar
        cmp w22, #9
        b.gt conv_done                                // Si es mayor que 9, terminar
        
        // Multiplicar el valor actual por 10 y añadir el nuevo dígito
        mul x20, x20, x21                             // valor = valor * 10
        add x20, x20, x22, UXTW                       // valor = valor + dígito
        
        b conv_loop
        
conv_done:
        // Retornar el valor convertido
        mov x0, x20
        
        // Restaurar registros
        ldp x21, x22, [sp], #16
        ldp x19, x20, [sp], #16
        ret

// =========================================
// Subrutina: int_to_str (Convierte entero en x1 a cadena en buffer apuntado por x2)
// Entrada: x1 = valor entero, x2 = dirección del buffer
// =========================================
int_to_str:
        // Guardar registros
        stp x19, x20, [sp, #-16]!                     // Guardar x19 y x20 en la pila
        stp x21, x22, [sp, #-16]!                     // Guardar x21 y x22 en la pila
        stp x23, x24, [sp, #-16]!                     // Guardar x23 y x24 en la pila
        
        mov x19, x1                                   // Guardar número original
        mov x20, x2                                   // Guardar dirección del buffer
        mov x21, #0                                   // Contador de dígitos
        
        // Caso especial: si el número es 0
        cbnz x19, convert_digits
        mov w22, #'0'
        strb w22, [x20]                               // Almacenar '0' en el buffer
        mov w22, #0
        strb w22, [x20, #1]                           // Terminar la cadena con nulo
        b int_to_str_done
        
convert_digits:
        // Convertir cada dígito y almacenarlo en el buffer temporalmente (al revés)
        mov x22, x20                                  // Puntero actual en el buffer
        
digit_loop:
        mov x0, x19                                   // Número actual
        mov x1, #10                                   // Divisor (10)
        udiv x23, x0, x1                              // x23 = x0 / 10 (cociente)
        msub x24, x23, x1, x0                         // x24 = x0 - (x23 * 10) (residuo)
        
        add w24, w24, #'0'                            // Convertir a ASCII
        strb w24, [x22], #1                           // Guardar dígito y avanzar puntero
        add x21, x21, #1                              // Incrementar contador de dígitos
        
        mov x19, x23                                  // Actualizar número con cociente
        cbnz x19, digit_loop                          // Continuar si aún hay dígitos
        
        // Invertir la cadena
        sub x22, x22, #1                              // x22 apunta al último dígito
        mov x23, x20                                  // x23 apunta al primer dígito
        
reverse_loop:
        cmp x23, x22
        b.ge reverse_done                             // Si x23 >= x22, terminamos
        
        // Intercambiar caracteres
        ldrb w24, [x23]
        ldrb w19, [x22]
        strb w19, [x23]
        strb w24, [x22]
        
        // Actualizar punteros
        add x23, x23, #1
        sub x22, x22, #1
        b reverse_loop
        
reverse_done:
        // Terminar la cadena con un nulo
        add x22, x20, x21                             // x22 = base + longitud
        mov w24, #0
        strb w24, [x22]                               // Almacenar nulo al final
        
int_to_str_done:
        // Restaurar registros
        ldp x23, x24, [sp], #16                       // Restaurar x23 y x24 de la pila
        ldp x21, x22, [sp], #16                       // Restaurar x21 y x22 de la pila
        ldp x19, x20, [sp], #16                       // Restaurar x19 y x20 de la pila
        ret

// =========================================
// Subrutina: print_str (Imprime una cadena terminada en NULL)
// Entrada: x0 = dirección de la cadena
// =========================================
print_str:
        mov x1, x0                                  // Dirección de la cadena a imprimir
        
        // Calcular la longitud de la cadena
        mov x2, #0                                  // Contador de longitud
str_len_loop:
        ldrb w3, [x1, x2]                           // Cargar byte de la cadena
        cbz w3, str_len_done                        // Si es cero, terminar
        add x2, x2, #1                              // Incrementar contador
        b str_len_loop
str_len_done:
        
        // Imprimir la cadena
        mov x0, #1                                  // File descriptor 1 (salida estándar)
        mov x8, #64                                 // Syscall para write
        svc #0
        ret
