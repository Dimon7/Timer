
typedef unsigned int uint;
typedef int sint;
typedef unsigned char uchar;
typedef unsigned long int ulong;


#define F_SCL 100000L   // „астота I2C 100 к√ц
#define F_CPU 8000000UL



#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <compat/deprecated.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "lcd.h"

#include "ds1307.h"
#include "i2cmaster.h"



 
 void WriteTime()
 {
	 unsigned char hours, minutes, seconds;
	 rtc_get_time(&hours,&minutes,&seconds);
	 lcd_putc(hours);
	 lcd_putc(':');
	 lcd_putc(minutes);
	 lcd_putc(':');
	 lcd_putc(seconds);
 }


int main(void){
	
	
	i2c_init();
	
	lcd_init(LCD_DISP_ON);
	
	
	while(1){
		lcd_gotoxy(1,0);
		lcd_clrscr();
		
		WriteTime();	

		_delay_ms(200);
		lcd_flush();
	}

	return 0 ;

}











