
#if (__GNUC__ * 100 + __GNUC_MINOR__) < 303
#error "This library requires AVR-GCC 3.3 or later, update to newer AVR-GCC compiler !"
#endif


#include <avr/io.h>
#include "i2cmaster.h"




;
#define SDA     	5
#define SCL			6	
#define SDA_PORT        PORTD           
#define SCL_PORT        PORTD           

;******

;-- map the IO register back into the IO address space
#define SDA_DDR		(_SFR_IO_ADDR(SDA_PORT) - 1)
#define SCL_DDR		(_SFR_IO_ADDR(SCL_PORT) - 1)
#define SDA_OUT		_SFR_IO_ADDR(SDA_PORT)
#define SCL_OUT		_SFR_IO_ADDR(SCL_PORT)
#define SDA_IN		(_SFR_IO_ADDR(SDA_PORT) - 2)
#define SCL_IN		(_SFR_IO_ADDR(SCL_PORT) - 2)

#define SCL_RELEASE cbi SCL_DDR,SCL
#define SCL_LOW sbi SCL_DDR,SCL
#define SDA_RELEASE cbi SDA_DDR,SDA
#define SDA_LOW sbi SDA_DDR,SDA

#ifndef __tmp_reg__
#define __tmp_reg__ 0
#endif


	.section .text

;*************************************************************************
; delay half period
; For I2C in normal mode (100kHz), use T/2 > 5us
; For I2C in fast mode (400kHz),   use T/2 > 1.3us
;*************************************************************************
	.stabs	"",100,0,0,i2c_delay_T2
	.stabs	"i2cmaster.S",100,0,0,i2c_delay_T2
	.func i2c_delay_T2	; delay 5.0 microsec with 4 Mhz crystal	
i2c_delay_T2:        ; 4 cycles
	rjmp 1f      ; 2   "
1:	rjmp 2f      ; 2   "
2:	rjmp 3f      ; 2   "
3:	rjmp 4f      ; 2   "
4:	rjmp 5f      ; 2   "
5: 	rjmp 6f      ; 2   "
6:	nop          ; 1   "
	ret          ; 3   "
	.endfunc     ; total 20 cyles = 5.0 microsec with 4 Mhz crystal 


;*************************************************************************
; Initialization of the I2C bus interface. Need to be called only once
; 
; extern void i2c_init(void)
;*************************************************************************
	.global i2c_init
	.func i2c_init
i2c_init:
	cbi SDA_OUT,SDA
	cbi SCL_OUT,SCL
	SDA_RELEASE		;release SDA
	SCL_RELEASE		;release SCL
	ret
	.endfunc


;*************************************************************************	
; Issues a start condition and sends address and transfer direction.
; return 0 = device accessible, 1= failed to access device
;
; extern unsigned char i2c_start(unsigned char addr);
;	addr = r24, return = r25(=0):r24
;*************************************************************************

	.global i2c_start
	.func   i2c_start
i2c_start:
	SDA_LOW	;force SDA low
	rcall 	i2c_delay_T2	;delay T/2
	
	rcall 	i2c_write	;write address
	ret
	.endfunc		


;*************************************************************************
; Issues a repeated start condition and sends address and transfer direction.
; return 0 = device accessible, 1= failed to access device
;
; extern unsigned char i2c_rep_start(unsigned char addr);
;	addr = r24,  return = r25(=0):r24
;*************************************************************************

	.global i2c_rep_start
	.func	i2c_rep_start
i2c_rep_start:
	SCL_LOW	;force SCL low
	rcall 	i2c_delay_T2	;delay  T/2
	SDA_RELEASE	;release SDA
	rcall	i2c_delay_T2	;delay T/2
	SCL_RELEASE	;release SCL
	rcall 	i2c_delay_T2	;delay  T/2
	SDA_LOW	;force SDA low
	rcall 	i2c_delay_T2	;delay	T/2
	
	rcall	i2c_write	;write address
	ret
	.endfunc


;*************************************************************************	
; Issues a start condition and sends address and transfer direction.
; If device is busy, use ack polling to wait until device is ready
;
; extern void i2c_start_wait(unsigned char addr);
;	addr = r24
;*************************************************************************

	.global i2c_start_wait
	.func   i2c_start_wait
i2c_start_wait:
	mov	__tmp_reg__,r24
i2c_start_wait1:
	SDA_LOW	;force SDA low
	rcall 	i2c_delay_T2	;delay T/2
	mov	r24,__tmp_reg__
	rcall 	i2c_write	;write address
	tst	r24		;if device not busy -> done
	breq	i2c_start_wait_done
	rcall	i2c_stop	;terminate write operation
	rjmp	i2c_start_wait1	;device busy, poll ack again
i2c_start_wait_done:
	ret
	.endfunc	


;*************************************************************************
; Terminates the data transfer and releases the I2C bus
;
; extern void i2c_stop(void)
;*************************************************************************

	.global	i2c_stop
	.func	i2c_stop
i2c_stop:
	SCL_LOW	;force SCL low
	SDA_LOW	;force SDA low
	rcall	i2c_delay_T2	;delay T/2
	SCL_RELEASE	;release SCL
	rcall	i2c_delay_T2	;delay T/2
	SDA_RELEASE	;release SDA
	rcall	i2c_delay_T2	;delay T/2
	ret
	.endfunc


;*************************************************************************
; Send one byte to I2C device
; return 0 = write successful, 1 = write failed
;
; extern unsigned char i2c_write( unsigned char data );
;	data = r24,  return = r25(=0):r24
;*************************************************************************
	.global i2c_write
	.func	i2c_write
i2c_write:
	sec			;set carry flag
	rol 	r24		;shift in carry and out bit one
	rjmp	i2c_write_first
i2c_write_bit:
	lsl	r24		;if transmit register empty
i2c_write_first:
	breq	i2c_get_ack
	SCL_LOW	;force SCL low
	brcc	i2c_write_low
	nop
	SDA_RELEASE	;release SDA
	rjmp	i2c_write_high
i2c_write_low:
	SDA_LOW	;force SDA low
	rjmp	i2c_write_high
i2c_write_high:
	rcall 	i2c_delay_T2	;delay T/2
	SCL_RELEASE	;release SCL
	rcall	i2c_delay_T2	;delay T/2
	rjmp	i2c_write_bit
	
i2c_get_ack:

	SCL_LOW	;force SCL low
	SDA_RELEASE	;release SDA

	rcall	i2c_delay_T2	;delay T/2

	SCL_RELEASE	;release SCL
i2c_ack_wait:
	sbis	SCL_IN,SCL	;wait SCL high (in case wait states are inserted)
	rjmp	i2c_ack_wait
	
	clr	r24		;return 0

	sbic	SDA_IN,SDA	;if SDA high -> return 1
	ldi	r24,1

	rcall	i2c_delay_T2	;delay T/2

	clr	r25

	ret
	.endfunc



;*************************************************************************
; read one byte from the I2C device, send ack or nak to device
; (ack=1, send ack, request more data from device 
;  ack=0, send nak, read is followed by a stop condition)
;
; extern unsigned char i2c_read(unsigned char ack);
;	ack = r24, return = r25(=0):r24
; extern unsigned char i2c_readAck(void);
; extern unsigned char i2c_readNak(void);
; 	return = r25(=0):r24
;*************************************************************************
	.global i2c_readAck
	.global i2c_readNak
	.global i2c_read		
	.func	i2c_read
i2c_readNak:
	clr	r24
	rjmp	i2c_read
i2c_readAck:
	ldi	r24,0x01
i2c_read:
	ldi	r23,0x01	;data = 0x01
i2c_read_bit:


	SCL_LOW	;force SCL low
	SDA_RELEASE	;release SDA (from previous ACK)
	rcall	i2c_delay_T2	;delay T/2
	
	SCL_RELEASE	;release SCL
	rcall	i2c_delay_T2	;delay T/2

i2c_read_stretch:
    sbis SCL_IN, SCL        ;loop until SCL is high (allow slave to stretch SCL)
    rjmp	i2c_read_stretch
	    
	clc			;clear carry flag
	sbic	SDA_IN,SDA	;if SDA is high
	sec			;  set carry flag
	
	rol	r23		;store bit
	brcc	i2c_read_bit	;while receive register not full
	
i2c_put_ack:
	SCL_LOW	;force SCL low	
	cpi	r24,1
	breq	i2c_put_ack_low	;if (ack=0)
	SDA_RELEASE	;      release SDA
	rjmp	i2c_put_ack_high
i2c_put_ack_low:                ;else
	SDA_LOW	;      force SDA low
i2c_put_ack_high:
	rcall	i2c_delay_T2	;delay T/2
	SCL_RELEASE	;release SCL
i2c_put_ack_wait:
	sbis	SCL_IN,SCL	;wait SCL high
	rjmp	i2c_put_ack_wait
	rcall	i2c_delay_T2	;delay T/2
	mov	r24,r23
	clr	r25
	ret
	.endfunc

