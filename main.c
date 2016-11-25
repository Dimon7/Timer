
typedef unsigned int uint;
typedef int sint;
typedef unsigned char uchar;
typedef unsigned long int ulong;

#define F_CPU 8000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <compat/deprecated.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "lcd.h"


int main(void){
	
	lcd_init(LCD_DISP_ON);
	while(1){
		lcd_gotoxy(0,0);
		lcd_clrscr();


		_delay_ms(20);
		lcd_puts("Init");
		lcd_flush();



	}

	return 0 ;

}











