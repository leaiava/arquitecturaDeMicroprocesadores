#include "board.h"
#include "c_func.h"
#include "asm_func.h"

#include <stdlib.h>
#include <stdnoreturn.h>
#include "cmsis.h"


// Variable que se incrementa cada vez que se llama al handler de interrupcion
// del SYSTICK.
static volatile uint32_t s_ticks = 0;


// Inicia soporte de la placa y periodo de la interrupcion del SYSTICK
// cada 1 milisegundo.
static void Inicio (void)
{
    Board_Init ();
    SystemCoreClockUpdate ();
    SysTick_Config (SystemCoreClock / 1000);
    //Board_Debug_Init();
}


// Segun la configuracion realizada en Inicio(), este handler de interrupcion
// se ejecutara cada 1 milisegundo.
void SysTick_Handler (void)
{
    ++ s_ticks;
}


static void Suma (void)
{
    const uint32_t A = 20;
    const uint32_t B = 30;

    const uint32_t SumResult_C = c_sum (A, B);
    const uint32_t SumResult_Asm = asm_sum (A, B);

    // Actividad de debug: SumResult_C y SumResult_Asm deberian contener el
    // mismo valor.
    __BKPT (0);

    (void) SumResult_C;
    (void) SumResult_Asm;
}

static void Zeros (void)
{
	volatile uint32_t * DWT_CTRL = (uint32_t *)0xE0001000;
	volatile uint32_t * DWT_CYCCNT = (uint32_t *)0xE0001004;
	uint32_t lectura;
	*DWT_CTRL |= 1;

	uint32_t vector[1000];
/*
	uint32_t vector[8] = { (uint32_t)-1, (uint32_t)-2, (uint32_t)-3,
						   (uint32_t)-4, (uint32_t)-5, (uint32_t)-6,
						   (uint32_t)-7, (uint32_t)-8 };
*/
	*DWT_CYCCNT=0;
	zeros (vector,1000);
	lectura = *DWT_CYCCNT;

	*DWT_CYCCNT=0;
	asm_zeros (vector,1000);
	lectura = *DWT_CYCCNT;
	*DWT_CYCCNT=0;
}
static void Producto32 (void)
{
	static uint32_t vectorIn[] = { 1, 200, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint32_t vectorOut[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint32_t escalar = 2;

	c_productoEscalar32(vectorIn, vectorOut, 10, escalar);

	asm_productoEscalar32(vectorIn, vectorOut, 10, escalar);
}
static void Producto16 (void)
{
	static uint16_t vectorIn[] = { 1, 200, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint16_t vectorOut1[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint16_t vectorOut2[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint32_t escalar = 2;

	c_productoEscalar16(vectorIn, vectorOut1, 10, escalar);

	asm_productoEscalar16(vectorIn, vectorOut2, 10, escalar);
}

static void Producto12 (void)
{
	// Activa contador de ciclos (iniciar una sola vez)
	DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

	static uint16_t vectorIn[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint16_t vectorOut1[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint16_t vectorOut2[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint16_t vectorOut3[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint16_t vectorOut4[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint32_t escalar = 2000;

	// Antes de la función a medir: contador de ciclos a cero
	DWT->CYCCNT = 0;
	c_productoEscalar12(vectorIn, vectorOut1, 10, escalar);
	volatile uint32_t ciclos = DWT->CYCCNT;
	printf("c:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	asm_productoEscalar12(vectorIn, vectorOut2, 10, escalar);
	ciclos = DWT->CYCCNT;
	printf("asm con subs:%d\r\n",ciclos);
	DWT->CYCCNT = 0;
	asm_productoEscalar12B(vectorIn, vectorOut3, 10, escalar);
	ciclos = DWT->CYCCNT;
	printf("asm con ands:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	asm_productoEscalar12SAT(vectorIn, vectorOut4, 10, escalar);
	ciclos = DWT->CYCCNT;
	printf("asm con usat:%d\r\n",ciclos);
}

static void Ventana10(void)
{
	// Activa contador de ciclos (iniciar una sola vez)
	DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

	static uint16_t vectorIn[] = { 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000,
								   100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 };
	static uint16_t vectorOut1[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	static uint16_t vectorOut2[]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

	DWT->CYCCNT = 0;
	c_filtroVentana10(vectorIn, vectorOut1, 20);
	volatile uint32_t ciclos = DWT->CYCCNT;
	printf("c_ventana10:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	asm_filtroVentana10(vectorIn, vectorOut2, 20);
	ciclos = DWT->CYCCNT;
	printf("asm_ventana10:%d\r\n",ciclos);
}

void pack32to16(void)
{
	// Activa contador de ciclos (iniciar una sola vez)
	DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

	static uint32_t vectorIn[] = {0x12345678, 0x23456789, 0x34567890, 0x87654321, 0x98765432};
	static uint16_t vectorOut1[5];
	static uint16_t vectorOut2[5];
	DWT->CYCCNT = 0;
	c_pack32to16(vectorIn, vectorOut1, 5);
	volatile uint32_t ciclos = DWT->CYCCNT;
	printf("c_pack32to16:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	asm_pack32to16(vectorIn, vectorOut2, 5);
	ciclos = DWT->CYCCNT;
	printf("asm_pack32to16:%d\r\n",ciclos);
}

void Max(void)
{
	// Activa contador de ciclos (iniciar una sola vez)
	DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

	static uint32_t vectorIn[] = { 1, 2, 10, 4, 5};
	volatile int32_t maximo;

	DWT->CYCCNT = 0;
	maximo = c_max(vectorIn, 5);
	volatile uint32_t ciclos = DWT->CYCCNT;
	printf("c_max:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	maximo = asm_max(vectorIn, 5);
	ciclos = DWT->CYCCNT;
	printf("asm_max:%d\r\n",ciclos);
}

void Invertir(void)
{
	// Activa contador de ciclos (iniciar una sola vez)
	DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

	static uint16_t vector1[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint16_t vector2[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

	DWT->CYCCNT = 0;
	c_invertir(vector1, 10);
	volatile uint32_t ciclos = DWT->CYCCNT;
	printf("c_invertir:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	asm_invertir(vector2, 10);
	ciclos = DWT->CYCCNT;
	printf("asm_invertir:%d\r\n",ciclos);
}

void Eco(void)
{
	// Activa contador de ciclos (iniciar una sola vez)
	DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos;

	static uint16_t vectorIn[4096] , vectorOut1[4096], vectorOut2[4096];


	for( uint32_t i = 0 ; i < 4096 ; i++)
	{
		vectorIn[i] = i ;
	}

	DWT->CYCCNT = 0;
	c_eco(vectorIn, vectorOut1);
	volatile uint32_t ciclos = DWT->CYCCNT;
	printf("c_eco:%d\r\n",ciclos);

	DWT->CYCCNT = 0;
	asm_eco(vectorIn, vectorOut2);
	ciclos = DWT->CYCCNT;
	printf("asm_eco:%d\r\n",ciclos);
}

static void LlamandoAMalloc (void)
{
    // De donde saca memoria malloc?
    // (se vera en clase)
    void * ptr = malloc (2048);

    (void) ptr;
}


static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo suma.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}


// Handler de la interrupcion "SVC" (Supervisor Call).
// Usado por el ejemplo "EjemploPrivilegiosSVC".
void SVC_Handler (void)
{
    // Se obtiene el valor del registro "control". El bit 0 indica el nivel
    // de privilegio en modo "Thread". Deberia ser 1: No privilegiado.
    uint32_t x = __get_CONTROL ();

    // Borra el bit 0. Nuevo valor 0: privilegiado.
    x &= ~1u;

    // Asigna el nuevo valor al registro "control". Esta operacion deberia
    // ejecutarse ya que todo manejador de interrupciones se ejecuta en modo
    // "Handler" con total privilegio.
    __set_CONTROL (x);
}


noreturn void LoopInfinito (void)
{
    while (1)
    {
        // Procesador en modo espera hasta que ocurra una interrupcion
        // (Bajo consumo)
        __WFI();
    }
}


int main (void)
{

	Inicio ();

    //Zeros ();

    //Producto32();

    //Producto16();

    //Producto12();

    //Ventana10();

	//pack32to16();

	//Max();

	//Invertir();

	Eco();

    //Suma ();

    //PrivilegiosSVC ();

    //LlamandoAMalloc ();

    LoopInfinito ();
}
