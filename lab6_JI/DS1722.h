// DS1722.h
// Driver for the DS1722 SPI digital thermometer (built on STM32L432KC_SPI).

#ifndef DS1722_H
#define DS1722_H

#include <stdint.h>
#include "STM32L432KC_GPIO.h"

// Chip enable (active HIGH on the DS1722)
#define DS1722_CE_PIN PA8

// Register addresses
#define DS1722_REG_CONFIG_RD 0x00
#define DS1722_REG_CONFIG_WR 0x80
#define DS1722_REG_TEMP_LSB  0x01
#define DS1722_REG_TEMP_MSB  0x02

/* Configures the CE pin and sets the sensor to continuous conversion at the
 * given resolution (8, 9, 10, 11 or 12 bits). Call after initSPI(0b101, 0, 0). */
void ds1722Init(int resolution_bits);

/* Changes resolution (8-12 bits). Values outside the range are clamped. */
void ds1722SetResolution(int resolution_bits);

/* Returns the resolution (bits) most recently written to the sensor. */
int ds1722GetResolution(void);

/* Reads the temperature registers. Returns a signed 8.8 fixed-point value:
 * degrees C = return / 256. */
int16_t ds1722ReadRaw(void);

/* Reads the configuration register (useful for debugging). */
uint8_t ds1722ReadConfig(void);

/* Formats the temperature as a string like "-12.3125" into buf (>= 12 bytes).
 * Number of decimals matches the resolution (8:0, 9:1, 10:2, 11:3, 12:4). */
void ds1722FormatTemp(char * buf, int16_t raw);

#endif // DS1722_H