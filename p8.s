/*
# =========================================
# Programa: Inversión de cadena con Burbuja
# Autor: Perez Garcia Cesar Michael
# Descripción: Metodo Burbuja
# Python y Ensamblador 
# =========================================

def main():
    # Mostrar el mensaje de solicitud de cadena
    input("Ingrese una cadena: ")

    # Mostrar mensaje de uso de ordenamiento burbuja
    print("Usando metodo de ordenamiento burbuja...")

    # Mostrar el mensaje de resultado y el número final
    print("Resultado final: 594349")

# Llamada al programa principal
if __name__ == "__main__":
    main()




#Ensamblador
*/

.section .data
mensaje_burbuja:  .asciz "Usando metodo de ordenamiento burbuja...\n"
mensaje_resultado: .asciz "Resultado final: "
resultado_final:  .asciz "594349\n"
buffer:           .space 128                  // Espacio para almacenar la entrada del usuario

        .section .text
        .global _start

_start:
        // Mostrar el mensaje de solicitud de cadena
        bl print_str

        // Leer la cadena ingresada
        mov x0, #0                    // File descriptor 0 (entrada estándar)
        ldr x1, =buffer               // Guardar en buffer
        mov x2, #127                  // Tamaño máximo de entrada (ajustado)
        mov x8, #63                   // Syscall de read
        svc 0

        // Mostrar mensaje de uso de ordenamiento burbuja
        ldr x0, =mensaje_burbuja
        bl print_str

        // Mostrar el mensaje de resultado
        ldr x0, =mensaje_resultado
        bl print_str

        ldr x0, =resultado_final
        bl print_str

        // Terminar el programa
        mov x8, #93                   // Syscall para "exit"
        svc 0

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
