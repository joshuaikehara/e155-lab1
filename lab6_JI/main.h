#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"
#include "DS1722.h"

#define DS1722_CE_PIN   PA8   // Chip Enable
#define SPI_SCK_PIN     PA5   // Serial Clock
#define SPI_MISO_PIN    PA6   // Master In Slave Out / SDO
#define SPI_MOSI_PIN    PB5   // Master Out Slave In / SDI

#define MCU_TX_PIN      PA9   // MCU TX -> ESP RX
#define MCU_RX_PIN      PA10  // MCU RX -> ESP TX
#define LED_PIN         PB3   // LED pin for blinking on Port B pin 3
#define BUFF_LEN 32

#endif // MAIN_H