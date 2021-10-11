#pragma once

#include <stdint.h>


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand);

void zeros (uint32_t * vector, uint32_t longitud);

void c_productoEscalar32 (uint32_t* vectorIn, uint32_t* vectorOut, uint32_t longitud, uint32_t escalar);

void c_productoEscalar16 (uint16_t* vectorIn, uint16_t* vectorOut, uint32_t longitud, uint16_t escalar);

void c_productoEscalar12 (uint16_t* vectorIn, uint16_t* vectorOut, uint32_t longitud, uint16_t escalar);

void c_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);

void c_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
