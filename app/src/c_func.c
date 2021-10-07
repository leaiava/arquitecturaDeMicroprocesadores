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

void c_productoEscalar12 (uint16_t* vectorIn, uint16_t* vectorOut, uint32_t longitud, uint16_t escalar){

	for(uint32_t i = 0 ; i < longitud ; i++){
		vectorOut[i] = vectorIn[i] * escalar;
		if (vectorOut[i] > 0x0FFF)
			vectorOut[i] = 0x0FFF;
		}

}

void c_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn){

	uint32_t aux=0;
	uint32_t j=0;

	if (longitudVectorIn < 10 || vectorIn == 0 || vectorOut == 0)
		return;

	for (uint32_t i = 0 ; i < longitudVectorIn ; i++){


		aux += vectorIn[i];
		if (i >= 10){
			aux -= vectorIn[j];
			j++;
		}

		vectorOut[i] = aux / (i-j+1);

	}
}
