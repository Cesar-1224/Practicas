# =========================================
# Programa: Inversión de cadena con Selección
# Autor: Pérez García César Michael
# Descripción: Solicita una cadena al usuario y aplica algoritmo de selección para invertirla
# Código en Python y Ensamblador
# =========================================

# Python
"""
def invertir_seleccion(cadena):
    """Invierte una cadena utilizando el método de selección."""
    if not cadena:
        return ""
    
    # Convertir cadena a lista para manipulación
    caracteres = list(cadena)
    n = len(caracteres)
    
    # Aplicar selección para intercambiar caracteres del inicio y fin
    for i in range(n // 2):
        # Seleccionar el carácter desde el inicio
        min_idx = i
        # Seleccionar el carácter desde el final (correspondiente al inicio)
        max_idx = n - i - 1
        # Intercambiar los caracteres
        caracteres[min_idx], caracteres[max_idx] = caracteres[max_idx], caracteres[min_idx]
    
    # Convertir lista de vuelta a cadena
    return ''.join(caracteres)

def main():
    # Solicitar cadena al usuario
    print("Ingrese una cadena: ", end='')
    cadena = input()
    
    # Invertir cadena
    print("Usando método de ordenamiento por selección...", end='\\n')
    cadena_invertida = invertir_seleccion(cadena)
    
    # Mostrar resultado
    print("Resultado final:", cadena_invertida)

if __name__ == "__main__":
    main()
"""

# Ensamblador ARM64
# Para ensamblar y enlazar:
# as -o inversion.o inversion.s
# ld -o inversion inversion.o

        .section .data
prompt:            .asciz "Ingrese una cadena: "
mensaje_seleccion: .asciz "Usando método de ordenamiento por selección...\n"
mensaje_resultado: .asciz "Resultado final: "
buffer_entrada:    .space 256                  // Buffer para la entrada del usuario
buffer_resultado:  .space 256                  // Buffer para almacenar resultado
nueva_linea:       .asciz "\n"                 // Carácter nueva línea

        .section .text
        .global _start

_start:
        // Mostrar el mensaje de solicitud de cadena
        ldr x0, =prompt
        bl print_str
        
        // Leer la cadena ingresada del usuario
        mov x0, #0                    // File descriptor 0 (entrada estándar)
        ldr x1, =buffer_entrada       // Guardar en buffer
        mov x2, #255                  // Tamaño máximo de entrada
        mov x8, #63                   // Syscall de read
        svc #0
        
        // Guardar la longitud de la cadena leída
        mov x19, x0                   // x19 = longitud de la cadena (incluye \n)
        
        // Eliminar el salto de línea si existe
        sub x2, x19, #1               // x2 = último índice
        ldr x1, =buffer_entrada
        ldrb w3, [x1, x2]
        cmp w3, #'\n'
        bne no_newline
        mov w3, #0                    // Reemplazar \n por \0
        strb w3, [x1, x2]
        sub x19, x19, #1              // Ajustar longitud
no_newline:
        
        // Aplicar método de selección para invertir la cadena
        ldr x0, =buffer_entrada       // Cadena original
        ldr x1, =buffer_resultado     // Cadena resultado
        mov x2, x19                   // Longitud de la cadena
        bl invertir_cadena
        
        // Mostrar mensaje de método usado
        ldr x0, =mensaje_seleccion
        bl print_str
        
        // Mostrar mensaje de resultado
        ldr x0, =mensaje_resultado
        bl print_str
        
        // Mostrar cadena invertida
        ldr x0, =buffer_resultado
        bl print_str
        
        // Imprimir nueva línea
        ldr x0, =nueva_linea
        bl print_str
        
        // Terminar el programa
        mov x8, #93                   // Syscall para "exit"
        mov x0, #0                    // Código de salida 0 (éxito)
        svc #0

// =========================================
// Subrutina: invertir_cadena (Invierte una cadena utilizando el método de selección)
// Entrada: x0 = dirección de la cadena original
//          x1 = dirección del buffer para el resultado
//          x2 = longitud de la cadena
// =========================================
invertir_cadena:
        // Guardar registros
        stp x19, x20, [sp, #-16]!
        stp x21, x22, [sp, #-16]!
        stp x23, x24, [sp, #-16]!
        
        mov x19, x0                   // x19 = cadena original
        mov x20, x1                   // x20 = buffer resultado
        mov x21, x2                   // x21 = longitud de la cadena
        
        // Primero, copiar la cadena al buffer de resultado
        mov x22, #0                   // x22 = índice
copy_loop:
        cmp x22, x21
        beq copy_done
        ldrb w23, [x19, x22]
        strb w23, [x20, x22]
        add x22, x22, #1
        b copy_loop
copy_done:
        // Añadir terminador de cadena
        mov w23, #0
        strb w23, [x20, x21]
        
        // Ahora invertir la cadena usando el método de selección
        mov x22, #0                   // i = 0
        lsr x23, x21, #1              // x23 = longitud/2
invert_loop:
        cmp x22, x23
        bge invert_done
        
        // Índice desde el inicio (i)
        mov x3, x22
        
        // Índice desde el final (longitud - i - 1)
        sub x4, x21, x22
        sub x4, x4, #1
        
        // Intercambiar caracteres
        ldrb w5, [x20, x3]           // Cargar carácter desde el inicio
        ldrb w6, [x20, x4]           // Cargar carácter desde el final
        strb w6, [x20, x3]           // Almacenar carácter del final en inicio
        strb w5, [x20, x4]           // Almacenar carácter del inicio en final
        
        add x22, x22, #1             // i++
        b invert_loop
        
invert_done:
        // Restaurar registros
        ldp x23, x24, [sp], #16
        ldp x21, x22, [sp], #16
        ldp x19, x20, [sp], #16
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
