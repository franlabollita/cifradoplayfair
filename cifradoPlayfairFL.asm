;                               Trabajo práctico Nro. 11
;                   Protección de información - Cifrado Playfair
;   La protección de información consiste en convertir un mensaje original en otro de forma tal que éste
;   sólo pueda ser recuperado por un grupo de personas a partir del mensaje codificado.
;   El sistema para llevar a cabo la protección deberá basarse en el álgebra lineal, con las siguientes
;   pautas:
;           - Alfabeto a utilizar 25 caracteres (A .. Z, omitiendo la J).
;           - Las letras son distribuidas en una matriz de 5x5.
;           - El mensaje a codificar deberá ser dividido en bloques de a dos caracteres (validando que ninguno de
;   los bloques contenga dos ocurrencias de la misma letra y la ‘J’).
;   La conversión se llevará a cabo por bloques, es decir tomando dos caracteres del mensaje por vez.
;           ● Si los caracteres se encuentran en distinta fila y columna de la matriz, considerar un rectángulo
;             formado con los caracteres como vértices y tomar de la misma fila la esquina opuesta.
;           ● Si los caracteres se encuentran en la misma fila, de cada caracter el situado a la derecha.
;           ● Si los caracteres se encuentran en la misma columna, tomar el caracter situado debajo.
;   Se pide desarrollar un programa en assembler Intel 80x86 que permita proteger información de la
;   manera antes descripta.
;   El mismo va a recibir como entrada:
;           ● El mensaje a codificar o codificado.
;           ● La matriz de 5x5.
;   El mismo va a dejar como salida:
;           ● El mensaje codificado u original.

global  main
extern puts
extern gets
extern printf 

section .data
    msjPedirFuncion             db          "Queres Cifrar o Decifrar un mensaje? (Marque 'C' para cifrar o 'D' para decifrar)",0
    msjPedirMensaje             db          "Ingrese su mensaje (Max. 100 caracteres):",0
    msjPedirMatriz              db          "Ingrese una Matriz 5x5 (Solo caracteres alfabeticos unicos omitiendo la letra 'J')",0
    msjFuncionInvalida          db          "Has ingresado un caracter invalido. Por favor ingrese 'C' para cifrar o 'D' para decifrar",0
    msjMatrizInvalida           db          "Has ingresado una matriz incompleta, con valores repetidos o con caracteres invalidos, intente denuevo.",0
    msjMensajeInvalida          db          "El mensaje ingresado no es valido, intente denuevo",0
    msjImprimirMensajeCifrado   db          "El mensaje cifrado/decifrado es: %s",0

    debuf db "%i",0
    
    matriz                  db          ' ',' ',' ',' ',' '
                            db          ' ',' ',' ',' ',' '
                            db          ' ',' ',' ',' ',' '
                            db          ' ',' ',' ',' ',' '
                            db          ' ',' ',' ',' ',' '
    
    longitudFila            dq          5
    longitudMensaje         dq          0
    bloqueActual            dq          0

    posicionesDelBloque		times	0 	dq      0
	  posicionPrimerChar                dq      0
      posicionSegundoChar               dq      0

    posicionMatricialPrimerChar      times	0 	dq      0
        filaPrimerChar                          dq      0
        columnaPrimerChar                       dq      0

    posicionMatricialSegundoChar     times	0 	dq      0
        filaSegundoChar                         dq      0
        columnaSegundoChar                      dq      0

    bloqueCifrado           times	0 	db      ''
        primerLetraCifrada              db      ' '
        segundaLetraCifrada             db      ' '

    finDeMensaje            db      "F"

section .bss
    mensajeACifrar          resb        100
    codigoFuncionElegida    resb        1
    matrizEntante           resb        26
    inputValido             resb        1
    mensajeCifrado          resb        100
    bloqueConExcepcion      resb        1
    bloqueMensaje           resb        2
    
section .text
main:
    mov         rcx,msjPedirFuncion
    sub         rsp,32  
    call        puts
    add         rsp,32

    mov         rcx,codigoFuncionElegida
    sub         rsp,32
    call        gets
    add         rsp,32

    sub         rsp,32
    call        validarCaracter
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          errorEnFuncion

    mov         rcx,msjPedirMatriz
    sub         rsp,32  
    call        puts
    add         rsp,32  

    mov         rcx,matrizEntante
    sub         rsp,32
    call        gets
    add         rsp,32

    sub         rsp,32  
    call        validarMatriz
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          errorEnMatriz

    mov         rcx,msjPedirMensaje
    sub         rsp,32  
    call        puts
    add         rsp,32  

    mov         rcx,mensajeACifrar
    sub         rsp,32
    call        gets
    add         rsp,32

    sub         rsp,32
    call        calcularLenMensaje
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          errorEnMensaje

    sub         rsp,32
    call        validarMensaje
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          errorEnMensaje

    sub         rsp,32
    call        cifrarMensaje    
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          errorEnMensaje

    sub         rsp,32
    call        imprimirMensajeCifrado    
    add         rsp,32

    jmp         endOfProgram

errorEnFuncion:
    mov         rcx,msjFuncionInvalida
    sub         rsp,32  
    call        puts
    add         rsp,32
    jmp         main

errorEnMatriz:
    mov         rcx,msjMatrizInvalida
    sub         rsp,32  
    call        puts
    add         rsp,32
    jmp         endOfProgram

errorEnMensaje:
    mov         rcx,msjMensajeInvalida
    sub         rsp,32  
    call        puts
    add         rsp,32

endOfProgram:
ret

validarCaracter:
    mov         byte[inputValido],'V'

    sub         rsp,32  
    call        calcularLenCodigo
    add         rsp,32

    cmp         byte[codigoFuncionElegida],'C'
    je          endOfValChar

    cmp         byte[codigoFuncionElegida],'c'
    je          endOfValChar

    cmp         byte[codigoFuncionElegida],'D'
    je          endOfValChar

    cmp         byte[codigoFuncionElegida],'d'
    je          endOfValChar

    mov         byte[inputValido],'F'

endOfValChar:
ret

validarMensaje:
    mov         byte[inputValido],'V'
    mov         rax,0

loopMensaje:
    sub         rsi,rsi
    mov         sil,byte[mensajeACifrar + rax]
    ;paso a mayuscula
    cmp         rsi,97
    jl          charMayuscula
    sub         rsi,32
    mov         byte[mensajeACifrar + rax],sil
charMayuscula:
    sub         rsp,32  
    call        validarCharActual
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          mensajeInvalido
    
    inc         rax
    cmp         [longitudMensaje],rax
    je          finValidacionMsj
    jmp         loopMensaje

mensajeInvalido:
    mov         byte[inputValido],'F'

finValidacionMsj:
ret

validarCharActual:
    mov         byte[inputValido],'V'                  
    mov         rbx,0                                 
	mov         r10,25                                  

loopCharsValidos:
    sub         rdi,rdi
	mov		    dil,byte[matriz + rbx]          
	cmp         rsi,rdi                                    
    je          charActualValido
	inc		    rbx  
    ;Si no es ninguna letra valida, me fijo si es ' '
    cmp         rbx,r10                          
    je          verificarCharActualEspacio      

	jmp         loopCharsValidos       

verificarCharActualEspacio:
    cmp         rsi,' '
	je          charActualValido

charActualInvalido:
	mov         byte[inputValido],'F'

charActualValido:
ret

calcularLenMensaje:
    ;inicalizo datos
    mov         rax,0
    mov         rbx,[mensajeACifrar]
    mov         byte[inputValido],'V'
loopLen:
    ;verifico que el char no sea en end of string
    sub         rcx,rcx
    mov         cl,byte[mensajeACifrar + rax]

    cmp         rcx,0
    je          endOfMensaje

sigueMensaje:
    inc        rax
    jmp        loopLen

endOfMensaje:
    cmp         rax,100
    jle         finLenM 

mensajeMuyLargo:
    mov         byte[inputValido],'F'

finLenM:
    mov         [longitudMensaje],ax

ret

calcularLenCodigo:
    ;inicalizo datos
    mov         rax,0
    mov         rbx,[codigoFuncionElegida]
    mov         byte[inputValido],'V'

loopLenCodigo:
    ;verifico que el char no sea en end of string
    sub         rcx,rcx
    mov         cl,byte[codigoFuncionElegida + rax]

    cmp         rcx,0
    je          endOfCodigo

sigueCodigo:
    inc        rax
    jmp        loopLenCodigo

endOfCodigo:
    cmp         rax,1
    je          finLC 

codigoErroneo:
    mov         byte[inputValido],'F'

finLC:
ret

calcularLenMatriz:
    ;inicalizo datos
    mov         rax,0
    mov         rbx,[matrizEntante]
    mov         byte[inputValido],'V'

loopLenMatriz:
    ;verifico que el char no sea en end of string
    sub         rcx,rcx
    mov         cl,byte[matrizEntante + rax]

    cmp         rcx,0
    je          endOfMatriz

sigueMatriz:
    inc        rax
    jmp        loopLenMatriz

endOfMatriz:
    cmp         rax,25
    je          finLM 

matrizErroneo:
    mov         byte[inputValido],'F'

finLM:
ret

validarMatriz:

    mov         byte[inputValido],'V'

    sub         rsp,32  
    call        calcularLenMatriz
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          finVM

    mov         rcx,0
    
loopMatrizValida:
    sub         rax,rax
    mov         al,byte[matrizEntante + rcx]

    cmp         rax,97
    jl          letraNoEsMinuscula
    sub         rax,32

letraNoEsMinuscula: 
    cmp         rax,65
    jl          matrizInvalida
    cmp         rax,90
    jg          matrizInvalida
    cmp         rax,74
    je          matrizInvalida

    sub         rsp,32
    call        validarUnicidadDeLetra   
    add         rsp,32
    cmp         byte[inputValido],'F'
    je          finVM

    mov         byte[matriz + rcx],al

    inc         rcx
    cmp         rcx,25
    je          finVM
    jmp         loopMatrizValida

matrizInvalida:
    mov         byte[inputValido],'F'

finVM:
ret

validarUnicidadDeLetra:
    mov         byte[inputValido],'V'
    mov         rdx,0
    cmp         rdx,rcx
    je          finVUDL

loopValidacionUnicidad:
    cmp         byte[matriz + rdx],al 
    je          letraRepetida

    inc         rdx
    cmp         rdx,rcx
    je          finVUDL
    jmp         loopValidacionUnicidad        

letraRepetida:
    mov         byte[inputValido],'F'

finVUDL:
ret

cifrarMensaje:
    ;cargo el bloque a cifrar
    sub         rsp,32
    call        cargarBloque    
    add         rsp,32
    ;valido si es necesario cifrar el bloque
    mov         byte[bloqueConExcepcion],'F'
    sub         rsp,32
    call        verificoBloquesConCharsIguales   
    add         rsp,32
    sub         rsp,32
    call        verificoBloqueConEspacio
    add         rsp,32
    cmp         byte[bloqueConExcepcion],'V'
    je          modificarResultado
    ;calculo las posiciones vectoriales del bloque
    sub         rsp,32
    call        calcularPosiconesDeChars    
    add         rsp,32
    ;calculo las posiciones matriciales del bloque
    sub         rsp,32
    call        encontarPosicionesMatriz    
    add         rsp,32
    ;veo si cifro o decifro
    cmp         byte[codigoFuncionElegida],'D'
    je          decifrarMensaje
    cmp         byte[codigoFuncionElegida],'d'
    je          decifrarMensaje
    ;cifro posiciones del bloque
    sub         rsp,32
    call        cifrar  
    add         rsp,32
    jmp         traducirALetra

decifrarMensaje:
    sub         rsp,32
    call        decifrar  
    add         rsp,32

traducirALetra:
    ;traduzco posiciones cifradas a su letra correspondiente
    sub         rsp,32
    call        posicionCifradaALetra    
    add         rsp,32

modificarResultado:
    ;agrego bloque cifrado al mensaje resultante
    sub         rsp,32
    call        agregarBloqueCifradoAResultado    
    add         rsp,32
    ;verifico si termino el mensaje
    sub         rsp,32
    call        verificoFinalMsj    
    add         rsp,32

    cmp         byte[finDeMensaje],'V'
    je          endCifradoMsj

    jmp         cifrarMensaje

endCifradoMsj:
ret

cargarBloque:
    mov         rax,[bloqueActual]
    mov         rcx,1
    lea         rsi,[mensajeACifrar + rax]
    lea         rdi,[bloqueMensaje]
    movsw       
    
ret

verificoBloquesConCharsIguales:
    ;Valido si los chars del bloque son iguales
    sub         rax,rax
    mov         al,byte[bloqueMensaje]
    mov         rcx,1
    sub         rbx,rbx
    mov         bl,byte[bloqueMensaje + rcx]

    cmp         rax,rbx
    je          charsIguales
    jmp         finCB

charsIguales:
    mov         byte[bloqueConExcepcion],'V'
    mov         rax,[bloqueMensaje]
    mov         [bloqueCifrado],rax

finCB: 
ret

verificoBloqueConEspacio:
    mov         rcx,0

verificoCharEspacio:
    sub         rax,rax
    mov         al,byte[bloqueMensaje + rcx]
    cmp         al,' '
    je          mantengoBloqueConEspacio
    inc         rcx
    cmp         rcx,2
    jne         verificoCharEspacio
    jmp         finVBCE

mantengoBloqueConEspacio:
    mov         byte[bloqueConExcepcion],'V'
    mov         rax,[bloqueMensaje]
    mov         [bloqueCifrado],rax;

finVBCE:
ret

calcularPosiconesDeChars:
    ;muevo el primer char a posicionPrimerChar
    mov         rcx,1
    lea         rsi,byte[bloqueMensaje]
    lea         rdi,[posicionPrimerChar]
    movsb
    ;calculo su posicoon
    mov         rax,[posicionPrimerChar]
    sub         rsp,32  
    call        calcularPosicion
    add         rsp,32

    mov         [posicionPrimerChar],rcx

    ;muevo el segundo char a posicionSegundoChar
    mov         rcx,1
    lea         rsi,byte[bloqueMensaje + rcx]
    lea         rdi,[posicionSegundoChar]
    movsb
    ;calculo su posicion
    mov         rax,[posicionSegundoChar]
    sub         rsp,32  
    call        calcularPosicion
    add         rsp,32

    mov         [posicionSegundoChar],rcx

ret

calcularPosicion:
    mov         rcx,0

loopPosicion:
    sub         rbx,rbx
    mov         bl,[matriz + rcx]

    cmp         al,bl
    je          encontroPosicion
    inc         rcx
    jmp         loopPosicion

encontroPosicion:
ret

encontarPosicionesMatriz:
    mov         rax,[posicionPrimerChar]
    mov         rbx,0

anotarFilaPrimerChar:
    cmp         rax,[longitudFila]
    jl          anotarColumnaPrimerChar

    sub         rax,[longitudFila]
    inc         rbx

    jmp         anotarFilaPrimerChar

anotarColumnaPrimerChar:
    mov         [filaPrimerChar],rbx
    mov         [columnaPrimerChar],rax

    ;Encuentro posicion cardenal del segundo elemento
    mov         rax,[posicionSegundoChar]
    mov         rbx,0

anotarFilaSegundoChar:
    cmp         rax,[longitudFila]
    jl          anotarColumnaSegundoChar

    sub         rax,[longitudFila]
    inc         rbx

    jmp         anotarFilaSegundoChar

anotarColumnaSegundoChar:
    mov         [filaSegundoChar],rbx
    mov         [columnaSegundoChar],rax

ret


cifrar:
    mov         rax,[columnaPrimerChar]
    cmp         rax,[columnaSegundoChar]
    je          cifradoPorColumna

    mov         rax,[filaPrimerChar]
    cmp         rax,[filaSegundoChar]
    je          cifradoPorFila

    jmp         cifradoTotal

cifradoPorColumna:
    cmp         qword[filaPrimerChar],4
    je         cifrarColumnaBordePrimerChar

    cmp         qword[filaSegundoChar],4
    je         cifrarColumnaBordeSegundoChar
 
    mov         rax,[filaSegundoChar]
    inc         rax
    mov         [filaSegundoChar],rax

    mov         rax,[filaPrimerChar]
    inc         rax
    mov         [filaPrimerChar],rax

    jmp         finCifrado

cifrarColumnaBordePrimerChar:
    mov         rax,[filaSegundoChar]
    inc         rax
    mov         [filaSegundoChar],rax

    mov         qword[filaPrimerChar],0
    jmp         finCifrado

cifrarColumnaBordeSegundoChar:
    mov         rax,[filaPrimerChar]
    inc         rax
    mov         [filaPrimerChar],rax

    mov         qword[filaSegundoChar],0
    jmp         finCifrado

cifradoPorFila:
    cmp         qword[columnaPrimerChar],4
    je         cifrarFilaBordePrimerChar

    cmp         qword[columnaSegundoChar],4
    je         cifrarFilaBordeSegundoChar

    mov         rax,[columnaSegundoChar]
    inc         rax
    mov         [columnaSegundoChar],rax

    mov         rax,[columnaPrimerChar]
    inc         rax
    mov         [columnaPrimerChar],rax

    jmp         finCifrado

cifrarFilaBordePrimerChar:
    mov         rax,[columnaSegundoChar]
    inc         rax
    mov         [columnaSegundoChar],rax

    mov         qword[columnaPrimerChar],0
    jmp         finCifrado

    jmp         finCifrado

cifrarFilaBordeSegundoChar:
    mov         rax,[columnaPrimerChar]
    inc         rax
    mov         [columnaPrimerChar],rax

    mov         qword[columnaSegundoChar],0
    jmp         finCifrado

    jmp         finCifrado

cifradoTotal:
    mov         rax,[columnaPrimerChar]
    mov         rbx,[columnaSegundoChar]
    mov         [columnaSegundoChar],rax
    mov         [columnaPrimerChar],rbx

finCifrado:
ret

decifrar:
    mov         rax,[columnaPrimerChar]
    cmp         rax,[columnaSegundoChar]
    je          descifradoPorColumna

    mov         rax,[filaPrimerChar]
    cmp         rax,[filaSegundoChar]
    je          descifradoPorFila

    jmp         descifradoTotal

descifradoPorColumna:
    cmp         qword[filaPrimerChar],0
    je         descifrarColumnaBordePrimerChar

    cmp         qword[filaSegundoChar],0
    je         descifrarColumnaBordeSegundoChar
    
    mov         rax,[filaSegundoChar]
    dec         rax
    mov         [filaSegundoChar],rax

    mov         rax,[filaPrimerChar]
    dec         rax
    mov         [filaPrimerChar],rax

    jmp         finDescifrado

descifrarColumnaBordePrimerChar:
    mov         rax,[filaSegundoChar]
    dec         rax
    mov         [filaSegundoChar],rax

    mov         qword[filaPrimerChar],4
    jmp         finDescifrado

descifrarColumnaBordeSegundoChar:
    mov         rax,[filaPrimerChar]
    dec         rax
    mov         [filaPrimerChar],rax

    mov         qword[filaSegundoChar],4
    jmp         finDescifrado

descifradoPorFila:
    cmp         qword[columnaPrimerChar],0
    je          descifrarFilaBordePrimerChar

    cmp         qword[columnaSegundoChar],0
    je          descifrarFilaBordeSegundoChar

    mov         rax,[columnaSegundoChar]
    dec         rax
    mov         [columnaSegundoChar],rax

    mov         rax,[columnaPrimerChar]
    dec         rax
    mov         [columnaPrimerChar],rax

    jmp         finDescifrado

descifrarFilaBordePrimerChar:
    mov         rax,[columnaSegundoChar]
    dec         rax
    mov         [columnaSegundoChar],rax

    mov         qword[columnaPrimerChar],4

    jmp         finDescifrado

descifrarFilaBordeSegundoChar:
    mov         rax,[columnaPrimerChar]
    dec         rax
    mov         [columnaPrimerChar],rax

    mov         qword[columnaSegundoChar],4
    jmp         finDescifrado

descifradoTotal:
    mov         rax,[columnaPrimerChar]
    mov         rbx,[columnaSegundoChar]
    mov         [columnaSegundoChar],rax
    mov         [columnaPrimerChar],rbx

finDescifrado:
ret

posicionCifradaALetra:
    ;primera letra
    mov         rax,[filaPrimerChar]
    imul        rax,qword[longitudFila]
    add         rax,qword[columnaPrimerChar]

    mov         rbx,[matriz + rax]
    mov         [primerLetraCifrada],rbx
    ;segunda letra
    mov         rax,[filaSegundoChar]
    imul        rax,qword[longitudFila]
    add         rax,qword[columnaSegundoChar]

    mov         rbx,[matriz + rax]
    mov         [segundaLetraCifrada],rbx

ret

agregarBloqueCifradoAResultado:
    mov         rax,[bloqueActual]
    sub         rdx,rdx
    mov         dx,word[bloqueCifrado]
    mov         [mensajeCifrado + rax],rdx    
    ;Actualizo el bloque counter
    mov         rbx,2
    add         [bloqueActual],rbx

ret

verificoFinalMsj:
    mov         rax,[longitudMensaje]
    sub         rax,[bloqueActual]
    cmp         rax,1
    jg          finVFM
    je          agregarCharExtra
    mov         byte[finDeMensaje],'V'
    jmp         finVFM

agregarCharExtra:
    mov         rax,[bloqueActual]

    sub         rdx,rdx
    mov         dl,byte[mensajeACifrar + rax]

    mov         byte[mensajeCifrado + rax],dl
    mov         byte[finDeMensaje],'V'

finVFM:
ret

imprimirMensajeCifrado:
    mov         rcx,msjImprimirMensajeCifrado
    mov         rdx,mensajeCifrado
    sub         rsp,32  
    call        printf
    add         rsp,32

ret 