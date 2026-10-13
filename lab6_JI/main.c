#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "main.h"

/////////////////////////////////////////////////////////////////
// Provided Constants and Functions
/////////////////////////////////////////////////////////////////

char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Web Server Demo Webpage</title>"
                     "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
                     "</head><body><h1>E155 Web Server Demo Webpage</h1>";

char* ledStr = "<p>LED Control:</p>"
               "<form action=\"ledon\"><input type=\"submit\" value=\"Turn the LED on!\"></form>"
               "<form action=\"ledoff\"><input type=\"submit\" value=\"Turn the LED off!\"></form>";

char* resStr = "<p>Resolution:</p>"
               "<form action=\"res8\" style=\"display:inline\"><input type=\"submit\" value=\"8-bit\"></form> "
               "<form action=\"res9\" style=\"display:inline\"><input type=\"submit\" value=\"9-bit\"></form> "
               "<form action=\"res10\" style=\"display:inline\"><input type=\"submit\" value=\"10-bit\"></form> "
               "<form action=\"res11\" style=\"display:inline\"><input type=\"submit\" value=\"11-bit\"></form> "
               "<form action=\"res12\" style=\"display:inline\"><input type=\"submit\" value=\"12-bit\"></form>";

char* webpageEnd = "</body></html>";

int inString(char request[], char des[]) {
    if (strstr(request, des) != NULL) { return 1; }
    return -1;
}

int updateLEDStatus(char request[]) {
    if (inString(request, "ledoff") == 1) {
        digitalWrite(LED_PIN, PIO_LOW);
    } else if (inString(request, "ledon") == 1) {
        digitalWrite(LED_PIN, PIO_HIGH);
    }
    return digitalRead(LED_PIN);
}

// Non-blocking resolution update (no delays)
void updateResolution(char request[]) {
    if      (inString(request, "res12") == 1) ds1722SetResolution(12);
    else if (inString(request, "res11") == 1) ds1722SetResolution(11);
    else if (inString(request, "res10") == 1) ds1722SetResolution(10);
    else if (inString(request, "res9")  == 1) ds1722SetResolution(9);
    else if (inString(request, "res8")  == 1) ds1722SetResolution(8);
}

#include <stdio.h>

void runSoftwareTests(void) {
    char testBuf[32];

    printf("\r\n=== DS1722 Format Unit Tests ===\r\n");

    // Test 1: +30.0000 deg C
    ds1722FormatTemp(testBuf, 0x1E00);
    printf("[TEST 1] Raw 0x1E00 (+30 C)     -> %s deg C\r\n", testBuf);

    // Test 2: +25.0625 deg C
    ds1722FormatTemp(testBuf, 0x1910);
    printf("[TEST 2] Raw 0x1910 (+25.0625 C) -> %s deg C\r\n", testBuf);

    // Test 3: 0.0000 deg C
    ds1722FormatTemp(testBuf, 0x0000);
    printf("[TEST 3] Raw 0x0000 (0 C)        -> %s deg C\r\n", testBuf);

    // Test 4: -0.5000 deg C
    ds1722FormatTemp(testBuf, 0xFF80);
    printf("[TEST 4] Raw 0xFF80 (-0.5 C)    -> %s deg C\r\n", testBuf);

    // Test 5: -10.0000 deg C
    ds1722FormatTemp(testBuf, 0xF600);
    printf("[TEST 5] Raw 0xF600 (-10 C)     -> %s deg C\r\n", testBuf);

    // Test 6: -10.1250 deg C
    ds1722FormatTemp(testBuf, 0xF5E0);
    printf("[TEST 6] Raw 0xF5E0 (-10.125 C) -> %s deg C\r\n", testBuf);

    printf("=================================\r\n\r\n");
}
int main(void) {
    configureFlash();
    configureClock();

    gpioEnable(GPIO_PORT_A);
    gpioEnable(GPIO_PORT_B);
    gpioEnable(GPIO_PORT_C);

    pinMode(LED_PIN, GPIO_OUTPUT);
    digitalWrite(LED_PIN, PIO_LOW);

    RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
    initTIM(TIM15);

    // Initialize USART1 at 125,000 baud
    USART_TypeDef * USART = initUSART(USART1_ID, 125000);

    // SPI1: Mode 1 (CPOL=0, CPHA=1)
    initSPI(0b101, 0, 1);
    ds1722Init(12);

    runSoftwareTests();

    while(1) {
        char request[BUFF_LEN];
        memset(request, 0, BUFF_LEN);
        int charIndex = 0;

        // Block until full newline-terminated request arrives from ESP8266
        while(inString(request, "\n") == -1) {
            while(!(USART->ISR & USART_ISR_RXNE));
            char c = readChar(USART);
            if (charIndex < BUFF_LEN - 1) {
                request[charIndex++] = c;
                request[charIndex] = '\0';
            }
        }

        // Apply commands immediately
        int led_status = updateLEDStatus(request);
        updateResolution(request);

        // Read dynamic data from DS1722 over SPI instantly
        char tempStr[16];
        ds1722FormatTemp(tempStr, ds1722ReadRaw());

        char ledStatusStr[20];
        if (led_status) sprintf(ledStatusStr, "LED is on!");
        else            sprintf(ledStatusStr, "LED is off!");

        char resInfoStr[32];
        sprintf(resInfoStr, "Current resolution: %d-bit", ds1722GetResolution());

        // Transmit complete HTML document immediately to avoid ESP8266 timeout
        sendString(USART, webpageStart);
        sendString(USART, ledStr);

        sendString(USART, "<h2>LED Status</h2><p>");
        sendString(USART, ledStatusStr);
        sendString(USART, "</p>");

        sendString(USART, "<h2>Temperature</h2><p>");
        sendString(USART, tempStr);
        sendString(USART, " &deg;C</p>");

        sendString(USART, resStr);
        sendString(USART, "<p>");
        sendString(USART, resInfoStr);
        sendString(USART, "</p>");

        sendString(USART, webpageEnd);
    }
}