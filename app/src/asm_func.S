.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global	asm_zeros
.global	asm_productoEscalar32

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
