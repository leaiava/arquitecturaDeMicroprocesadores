#include "c_func.h"


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand)
{
    return (firstOperand + secondOperand);
}

void zeros (uint32_t * vector, uint32_t longitud)
{
	for(uint32_t i = 0 ; i<longitud ; i++ )
		vector[i]=0;
}

void c_productoEscalar32 (uint32_t* vectorIn, uint32_t* vectorOut, uint32_t longitud, uint32_t escalar){

	for(uint32_t i = 0 ; i < longitud ; i++){
		vectorOut[i] = vectorIn[i] * escalar;
	}
}
void c_productoEscalar16 (uint16_t* vectorIn, uint16_t* vectorOut, uint32_t longitud, uint16_t escalar){
	for(uint32_t i = 0 ; i < longitud ; i++){
		vectorOut[i] = vectorIn[i] * escalar;
		}
}
