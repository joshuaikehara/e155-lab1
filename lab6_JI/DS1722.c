// DS1722.c
// Driver for the DS1722 SPI digital thermometer (built on STM32L432KC_SPI).

#include "STM32L432KC.h"
#include "DS1722.h"

static int currentResolution = 12;

static void ceHigh(void) {
    digitalWrite(DS1722_CE_PIN, PIO_HIGH);
    for (volatile int i = 0; i < 50; i++); // CE setup delay per datasheet
}

static void ceLow(void) {
    while (SPI1->SR & SPI_SR_BSY);          // Wait for SPI clock edge to finish
    for (volatile int i = 0; i < 50; i++); // CE hold delay per datasheet
    digitalWrite(DS1722_CE_PIN, PIO_LOW);
}

static void writeReg(uint8_t addr, uint8_t value) {
    ceHigh();
    spiSendReceive((char) addr);
    spiSendReceive((char) value);
    ceLow();
}

static uint8_t readReg(uint8_t addr) {
    ceHigh();
    spiSendReceive((char) addr);
    uint8_t value = (uint8_t) spiSendReceive(0x00);
    ceLow();
    return value;
}

void ds1722SetResolution(int resolution_bits) {
    if (resolution_bits < 8)  resolution_bits = 8;
    if (resolution_bits > 12) resolution_bits = 12;

    // Do not rewrite config register if resolution is already set
    if (resolution_bits == currentResolution) return;

    uint8_t r = (uint8_t)(resolution_bits - 8);
    writeReg(DS1722_REG_CONFIG_WR, (uint8_t)(0xE0 | (r << 1)));
    currentResolution = resolution_bits;
}

void ds1722Init(int resolution_bits) {
    pinMode(DS1722_CE_PIN, GPIO_OUTPUT);
    digitalWrite(DS1722_CE_PIN, PIO_LOW);

    // High output speed on DS1722_CE_PIN (PA8)
    GPIOA->OSPEEDR |= (0b11U << (2 * gpioPinOffset(DS1722_CE_PIN)));

    ds1722SetResolution(resolution_bits);
}

int ds1722GetResolution(void) {
    return currentResolution;
}

uint8_t ds1722ReadConfig(void) {
    return readReg(DS1722_REG_CONFIG_RD);
}

int16_t ds1722ReadRaw(void) {
    // Continuous burst read: address 0x01 (LSB) auto-increments to 0x02 (MSB)
    ceHigh();
    spiSendReceive(DS1722_REG_TEMP_LSB);
    uint8_t lsb = (uint8_t) spiSendReceive(0x00);
    uint8_t msb = (uint8_t) spiSendReceive(0x00);
    ceLow();

    return (int16_t)(((uint16_t) msb << 8) | lsb);
}

void ds1722FormatTemp(char * buf, int16_t raw) {
    int32_t v = raw;
    char * p = buf;

    if (v < 0) { 
        *p++ = '-'; 
        v = -v; 
    }

    int whole = (int)(v >> 8);     // Integer degrees
    int frac  = (int)(v & 0xFF);   // 1/256 fractional units

    if (whole >= 100) *p++ = (char)('0' + whole / 100);
    if (whole >= 10)  *p++ = (char)('0' + (whole / 10) % 10);
    *p++ = (char)('0' + whole % 10);

    int decimals = currentResolution - 8; // 8-bit:0 ... 12-bit:4 decimals
    if (decimals > 0) {
        *p++ = '.';
        for (int i = 0; i < decimals; i++) {
            frac *= 10;
            *p++ = (char)('0' + (frac >> 8));
            frac &= 0xFF;
        }
    }
    *p = '\0';
}