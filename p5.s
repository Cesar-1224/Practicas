/*
# =========================================
# Programa: Encontrar el mínimo en un arreglo
# Autor: Perez Garcia Cesar Michael
# Descripción: Encuentra el valor mínimo en un arreglo precargado y muestra el resultado en consola.
# Codigo en python y ensamblador
# =========================================

# Definición del arreglo
arreglo = [505, 304, 360, 90, 820, 450, 670, 230]  # Arreglo de enteros precargado

def encontrar_minimo(arreglo):
    # Inicializar el mínimo con el primer elemento del arreglo
    minimo = arreglo[0]
    for num in arreglo[1:]:
        if num < minimo:
            minimo = num
    return minimo

# Encontrar el valor mínimo en el arreglo
minimo = encontrar_minimo(arreglo)

# Mostrar el resultado
print("El valor mínimo es:", minimo)





#Ensamblador
*/

 .section .data
mensaje_resultado: .asciz "El valor mínimo es: "
arreglo:          .quad 505, 304, 360, 90, 820, 450, 670, 230 // Arreglo de enteros precargado
tamanio_arreglo:  .quad 8                   // Tamaño del arreglo

        .section .text
        .global _start

_start:
        // Cargar la dirección del arreglo y su tamaño
        ldr x1, =arreglo               // Dirección del arreglo en x1
        ldr x0, =tamanio_arreglo       // Tamaño del arreglo en x0
        ldr x0, [x0]                   // Leer el tamaño en x0

        // Llamada a la subrutina para encontrar el mínimo
        bl find_min                    // Al regresar, el mínimo está en x3

        // Mostrar el mensaje de resultado
        ldr x0, =mensaje_resultado
        bl print_str

        // Imprimir el número mínimo
        mov x0, x3                     // Pasar el mínimo a x0 para imprimir
        bl print_num                   // Imprimir el número en consola

        // Terminar el programa
        mov x8, #93                    // Syscall para "exit"
        svc 0

// =========================================
// Subrutina: find_min (Encuentra el mínimo en el arreglo en x1 de longitud x0)
// =========================================
find_min:
        ldr x3, [x1]                   // Inicializar x3 con el primer elemento como el mínimo
        mov x2, #1                     // Índice inicial (segundo elemento)

loop:
        cmp x2, x0                     // Comparar índice con el tamaño del arreglo
        b.ge end_find_min              // Si índice >= tamaño, termina

        ldr x4, [x1, x2, lsl #3]       // Cargar el siguiente elemento en x4
        cmp x3, x4                     // Comparar mínimo actual con el elemento
        csel x3, x3, x4, lt            // Si x3 < x4, mantener x3; de lo contrario, x3 = x4

        add x2, x2, #1                 // Incrementar el índice
        b loop

end_find_min:
        ret

// =========================================
// Subrutina: print_str (Imprime una cadena terminada en NULL en x0)
// =========================================
print_str:
        mov x8, #64                    // Syscall para write
        mov x1, x0                     // Dirección de la cadena a imprimir
        mov x2, #128                   // Longitud máxima del mensaje
        mov x0, #1                     // File descriptor 1 (salida estándar)
        svc 0
        ret

// =========================================
// Subrutina: print_num (Imprime un número en x0 en consola)
// =========================================
print_num:
        // Aquí va la lógica para convertir x0 a ASCII y enviarlo a consola.
        // Por simplicidad, imprime el valor como texto.
        ret
