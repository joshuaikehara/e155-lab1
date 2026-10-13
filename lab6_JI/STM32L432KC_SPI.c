// STM32L432KC_SPI.c
// SPI1 master driver for the STM32L432KC using CMSIS register definitions.

#include "STM32L432KC.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include "main.h"

void initSPI(int br, int cpol, int cpha) {
    // Clocks for GPIOA, GPIOB, and SPI1
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN;
    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

    // PA5 = SCK, PA6 = MISO, PB5 = MOSI -> Alternate Function 5
    // Using defines in pinMode
    pinMode(SPI_SCK_PIN, GPIO_ALT);
    pinMode(SPI_MISO_PIN, GPIO_ALT);
    pinMode(SPI_MOSI_PIN, GPIO_ALT);



    GPIOA->AFR[0] &= ~((0xFU << GPIO_AFRL_AFSEL5_Pos) | (0xFU << GPIO_AFRL_AFSEL6_Pos));
    GPIOA->AFR[0] |=  (5U << GPIO_AFRL_AFSEL5_Pos) | (5U << GPIO_AFRL_AFSEL6_Pos);

    GPIOB->AFR[0] &= ~(0xFU << GPIO_AFRL_AFSEL5_Pos);
    GPIOB->AFR[0] |=  (5U << GPIO_AFRL_AFSEL5_Pos);

    // High output speed on SPI pins
    GPIOA->OSPEEDR |= (0b11U << (2 * gpioPinOffset(SPI_SCK_PIN))) | 
                      (0b11U << (2 * gpioPinOffset(SPI_MISO_PIN)));
    GPIOB->OSPEEDR |= (0b11U << (2 * gpioPinOffset(SPI_MOSI_PIN)));

    // Disable SPI peripheral during configuration
    SPI1->CR1 &= ~SPI_CR1_SPE;

    // CR1: baud rate, polarity/phase, master mode, software NSS
    uint32_t cr1 = 0;
    cr1 |= ((uint32_t)(br & 0b111) << SPI_CR1_BR_Pos);
    if (cpol) cr1 |= SPI_CR1_CPOL;
    if (cpha) cr1 |= SPI_CR1_CPHA;
    cr1 |= SPI_CR1_MSTR;              // Master mode
    cr1 |= SPI_CR1_SSM | SPI_CR1_SSI; // Software slave management
    SPI1->CR1 = cr1;

    // CR2: 8-bit data size (DS = 0b0111), RXNE threshold at 8 bits (FRXTH = 1)
    SPI1->CR2 = (0b0111U << SPI_CR2_DS_Pos) | SPI_CR2_FRXTH;

    // Enable SPI peripheral
    SPI1->CR1 |= SPI_CR1_SPE;
}

char spiSendReceive(char send) {
    volatile uint8_t * dr = (volatile uint8_t *) &SPI1->DR;

    // Flush lingering data in RX FIFO before transaction
    while (SPI1->SR & SPI_SR_RXNE) {
        (void)*dr;
    }

    while (!(SPI1->SR & SPI_SR_TXE));   // Wait for room in TX FIFO
    *dr = (uint8_t) send;
    while (!(SPI1->SR & SPI_SR_RXNE));  // Wait for received byte
    return (char) *dr;
}