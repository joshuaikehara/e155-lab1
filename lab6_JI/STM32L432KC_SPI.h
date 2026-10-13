// STM32L432KC_SPI.h
// Header for SPI1 master driver (CMSIS register structs from stm32l432xx.h)

#ifndef STM32L4_SPI_H
#define STM32L4_SPI_H

#include <stdint.h>
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Pin assignments (SPI1, alternate function 5)
///////////////////////////////////////////////////////////////////////////////
// PA5 = SCK, PA6 = MISO (SDO of DS1722), PB5 = MOSI (SDI of DS1722)
// Chip enable is driven as a plain GPIO (PA8).

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

/* Enables SPI1 as a master and initializes clock speed, polarity, and phase.
 *   -- br: Baud rate divider (0b000 - 0b111). Clock = APB2 clock / 2^(BR+1).
 *   -- cpol: Clock polarity (0: idle low, 1: idle high).
 *   -- cpha: Clock phase (0: capture on 1st edge, 1: capture on 2nd edge).
 * Configures 8-bit frames, MSB first, software slave management. */
void initSPI(int br, int cpol, int cpha);

/* Transmits a byte over SPI and returns the byte received simultaneously.
 *   -- send: byte to send
 *   -- return: byte received */
char spiSendReceive(char send);

#endif // STM32L4_SPI_H