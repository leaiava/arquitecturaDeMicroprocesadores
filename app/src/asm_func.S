#define TAMANIO_VENTANA	10
.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global	asm_zeros
.global	asm_productoEscalar32
.global	asm_productoEscalar16
.global	asm_productoEscalar12
.global	asm_productoEscalar12B
.global	asm_productoEscalar12SAT
.global	asm_filtroVentana10
.global asm_pack32to16

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_zeros (uint32_t *vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
@
.thumb_func
	asm_zeros:
		@ r2: valor cero
		mov	r2,	0			@ constante cero
		mov r3,	0			@
	.loop:
		str	r2, [r0], 4		@ sizeof(uint32_t) = 4 por eso hago un post incremento de 4
		subs	r1, 1		@ --longitud agrego la "s" para que la instrucción actualice los flags
	    beq .fin 			@ Si da cero salto al fin
   	str r2, [r0], 4
    	subs r1, 1
    	beq .fin 			@ Si da cero salto al fin
   	str r2, [r0], 4
    	subs r1, 1
		bne	.loop			@ salto mientras flag Z=0, cuando flag Z=1 (r1=0) no hago el salto a .loop
	.fin:
		bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@
.thumb_func
	asm_productoEscalar32:
		//push	{r4}			@ r4 lo voy a usar para tener el resultado de la multiplicacion
		//push	{r5}			@ r5 lo voy a usar para cargar el valor de [r0]
		push	{r4-r5}			@ Hago lo mismo que las 2 instrucciones anteriores pero todo en una
	.loop2:
		ldr		r5, [r0], 4		@ cargo en r5 el valor apuntado por r0 e incremento r0 en 4
		mul		r4, r5, r3		@ r4 = r5 * r3
		str		r4, [r1], 4		@ cargo el resultado de la multiplicacion en [r1] e incremento en 4 a r1
		subs	r2, 1			@ --longitud y modifico los flags
		bne		.loop2			@ si llegue a cero salgo del loop2
		//pop		{r5}			@ recupero r5
		//pop		{r4}		@ recupero r4
		pop		{r4-r5}			@ Hago lo mismo que las 2 instrucciones anteriores pero todo en una
		bx		lr				@ retorno


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@
.thumb_func
	asm_productoEscalar16:
		push	{r4-r5}		@ r4 lo voy a usar para tener el resultado de la multiplicacion
							@ r5 lo voy a usar para cargar el valor de [r0]
	.loop3:
		ldrh	r5, [r0], 2		@ cargo en r5 el valor apuntado por r0 e incremento r0 en 4
		mul		r4, r5, r3		@ r4 = r5 * r3
		strh	r4, [r1], 2		@ cargo el resultado de la multiplicacion en [r1] e incremento en 4 a r1
		subs	r2, 1			@ --longitud y modifico los flags
		bne		.loop3			@ si llegue a cero salgo del loop2
		pop		{r4-r5}			@ recupero r5 y recupero r4
		bx	lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@

.thumb_func
	asm_productoEscalar12:
		push	{r4-r7}		@ r4 lo voy a usar para tener el resultado de la multiplicacion
							@ r5 lo voy a usar para cargar el valor de [r0]
							@ r6 lo uso para tener cargado el valor 0x0FFF
							@ r7 para calcular la resta que compara si la multiplicacion es mayor a 12bits (0x0FFF)
		subs	r4, r0, 1	@ le resto 1 a r0, si da negativo es que era null
		bmi		.fin4		@ Si dio negativo salto, sino sigue
		subs	r4, r1, 1	@ le resto 1 a r1, si da negativo es que era null y termino
		bmi		.fin4
		movw	r6, 0x0FFF
	.loop4:
		ldrh	r5, [r0], 2		@ cargo en r5 el valor apuntado por r0 e incremento r0 en 2
		mul		r4, r5, r3		@ r4 = r5 * r3
		subs	r7, r4, r6		@ le resto al resultado de la multiplicación 0X0FFF
		bmi		.menorA12bits	@ Si da negativo salto, significa que la multiplicacion es menor a 0x0FFF
		mov		r4, r6			@ Si no salto es porque la multiplicacion es mayor a 0x0FFF, muevo 0x0FFF como resultado saturado
	.menorA12bits:
		strh	r4, [r1], 2		@ cargo el resultado de la multiplicacion en [r1] e incremento en 2 a r1
		subs	r2, 1			@ --longitud y modifico los flags
		bne		.loop4			@ si llegue a cero salgo del loop2
	.fin4:
		pop		{r4-r7}			@ recupero r5 y recupero r4
		bx	lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@

.thumb_func
	asm_productoEscalar12B:
		push	{r4-r5}		@ r4 lo voy a usar para tener el resultado de la multiplicacion
							@ r5 lo voy a usar para cargar el valor de [r0]
							@ r6 lo uso para tener cargado el valor 0x0FFF
							@ r7 para calcular la resta que compara si la multiplicacion es mayor a 12bits (0x0FFF)
		subs	r4, r0, 1	@ le resto 1 a r0, si da negativo es que era null
		bmi		.fin5		@ Si dio negativo salto, sino sigue
		subs	r4, r1, 1	@ le resto 1 a r1, si da negativo es que era null y termino
		bmi		.fin5
	.loop5:
		ldrh	r4, [r0], 2		@ cargo en r5 el valor apuntado por r0 e incremento r0 en 2
		mul		r4, r3			@ r4 = r4 * r3
		ands	r5, r4, 0xF000
		beq		.not_saturate
		movw	r4, 0xFFF		@ le resto al resultado de la multiplicación 0X0FFF
	.not_saturate:
		strh	r4, [r1], 2		@ cargo el resultado de la multiplicacion en [r1] e incremento en 2 a r1
		subs	r2, 1			@ --longitud y modifico los flags
		bne		.loop5			@ si llegue a cero salgo del loop2
	.fin5:
		pop		{r4-r5}			@ recupero r5 y recupero r4
		bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
@

.thumb_func
	asm_productoEscalar12SAT:
		push	{r4-r5}		@ r4 lo voy a usar para tener el resultado de la multiplicacion
							@ r5 lo voy a usar para cargar el valor de [r0]
		subs	r4, r0, 1	@ le resto 1 a r0, si da negativo es que era null
		bmi		.fin6		@ Si dio negativo salto, sino sigue
		subs	r4, r1, 1	@ le resto 1 a r1, si da negativo es que era null y termino
		bmi		.fin6
	.loop6:
		ldrh	r4, [r0], 2		@ cargo en r4 el valor apuntado por r0 e incremento r0 en 2
		mul		r4, r3			@ r4 = r4 * r3
		usat	r4, 12, r4
		strh	r4, [r1], 2		@ cargo el resultado de la multiplicacion en [r1] e incremento en 2 a r1
		subs	r2, 1			@ --longitud y modifico los flags
		bne		.loop6			@ si llegue a cero salgo del loop2
	.fin6:
		pop		{r4-r5}			@ recupero r5 y recupero r4
		bx	lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ extern void asm_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud

.thumb_func
	asm_filtroVentana10:
		push	{r3-r8}		@ r3 lo voy a usar para ver si los argumentos son correctos
							@ Luego r3 lo uso para tener otro indice aparte del de longuitud
							@ r4 lo uso de auxiliar
							@ r5 lo voy a usar para cargar el valor de [r0]
							@ r6 auxiliar para tner la resta entre indices.
							@ r7 auxiliar para tener el resultado de la division
							@r8 para tener copia de r0
		subs	r3, r0, 1	@ le resto 1 a r0, si da negativo es que era null
		bmi		.fin7		@ Si dio negativo salto, sino sigue
		subs	r3, r1, 1	@ le resto 1 a r1, si da negativo es que era null y termino
		bmi		.fin7
		subs	r3, r2, TAMANIO_VENTANA	@ le resto 10, si da negativo es que la longitud es menor a 10
		bmi		.fin7
		mov		r8, r0		@ copia de r0 para tener otro indie.

		mov		r4, 0		@ inicializo r4 en 0
		mov		r3, r2		@ Muevo Longitud a r3 para tener otro indice de longitud.
	.lazo1:					@ bucle para hacer la suma de los ultimos 10 lugares
		ldrh	r5, [r0], 2	@ cargo en r5 el valor apuntado por r0 e incremento r0 en 2
		add		r4, r5		@ r4 = r4 + r5
		subs	r3, 1		@ le resto 1 al indice en r3
		subs	r6, r2, r3	@ r6 = r2 - r3
		udiv	r7, r4, r6	@ r7 = r4 / r6
		strh	r7, [r1], 2	@ Cargo en memoria, en la dirección de r1 el resultado de la division e incremento en 2
		cmp		r6, TAMANIO_VENTANA	@ comparo contra 10, si son iguales dejo de saltar.
		bne		.lazo1
		ldrh	r5, [r8], 2 @ Cargo en r5 el primer valor para restar
		sub		r2, 1
		sub		r4, r5		@ r4 = r4 - r5
		cmp		r3, 0
		bne		.lazo1		@ mientras no sea cero sigo en el bucle, cuando llegué a cero termine

	.fin7:
		pop		{r3-r8}		@ recupero registros
		bx	lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ extern void asm_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: variable auxiliar
.thumb_func
	asm_pack32to16:
		push	{r3}		@ r3 lo voy a usar para ver si los argumentos son correctos
		cmp		r0, 0		@ comparo con cero
		beq		.fin8		@ Si dio que son iguales la comparacion salto
		cmp		r1, 0
		beq		.fin8
		cmp		r2, 0
		beq		.fin8
	.loop8:
		ldr		r3, [r0], 4
		lsr		r3, 16
		str		r3, [r1], 2
		subs	r2, 1
		bne		.loop8
	.fin8:
		pop		{r3}
		bx		lr
