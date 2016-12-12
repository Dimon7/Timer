// ������ � ������ DS1307 (i2c)
#include "i2c_master.h"
#include "i2cmaster.S"
//#include "i2cmaster.h"


unsigned char bcd2bin(unsigned char x){
    return (((x & 0xF0)>>4)*10 + (x & 0x0F));
}

unsigned char bin2bcd(unsigned char x){
    return ((x%10) | ((x/10)<<4));
}

void rtc_init(unsigned char PeriodSelect,   // ����� ������� �� ������ OUT
                                            // 0 - 1 ��
                                            // 1 - 4096 ��
                                            // 2 - 8192 ��
                                            // 3 - 32768 ��
              unsigned char SQWe,           // ��������� ������� �� ������ OUT
              unsigned char OUTlevel        // ������� �� OUT, ���� SQWe==0
              ){
    PeriodSelect &= 3;
    // ������������� ����� ��� ������ � �������
    if (SQWe) PeriodSelect |= 0x10;
    if (OUTlevel) PeriodSelect |= 0x80;
    // ������� � ����
    i2c_start(0xd0);
    i2c_write(7);
    i2c_write(PeriodSelect);
    i2c_stop();
}

void rtc_get_time(unsigned char *hour,unsigned char *min,unsigned char *sec){
    i2c_start(0xd0);
    i2c_write(0);
	i2c_stop();
    i2c_start(0xd1);
    *sec = bcd2bin(i2c_read(1));
    *min = bcd2bin(i2c_read(1));
    *hour = bcd2bin(i2c_read(0));
    i2c_stop();
}

void rtc_set_time(unsigned char hour,unsigned char min,unsigned char sec){
    i2c_start(0xd0);
    i2c_write(0);
    i2c_write(bin2bcd(sec));
    i2c_write(bin2bcd(min));
    i2c_write(bin2bcd(hour));
    i2c_stop();
}

void rtc_get_date(unsigned char *date,unsigned char *month,unsigned char *year){
    i2c_start(0xd0);
    i2c_write(4);
    i2c_start(0xd1);
    *date=bcd2bin(i2c_read(1));
    *month=bcd2bin(i2c_read(1));
    *year=bcd2bin(i2c_read(0));
    i2c_stop();
}

void rtc_set_date(unsigned char date,unsigned char month,unsigned char year){
    i2c_start(0xd0);
    i2c_write(4);
    i2c_write(bin2bcd(date));
    i2c_write(bin2bcd(month));
    i2c_write(bin2bcd(year));
    i2c_stop();
}
