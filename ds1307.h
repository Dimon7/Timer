#ifndef _ds1307_h_
#define _ds1307_h_ 1



void rtc_init(unsigned char PeriodSelect,   // ����� ������� �� ������ OUT
                                            // 0 - 1 ��
                                            // 1 - 4096 ��
                                            // 2 - 8192 ��
                                            // 3 - 32768 ��
              unsigned char SQWe,           // ��������� ������� �� ������ OUT
              unsigned char OUTlevel        // ������� �� OUT, ���� SQWe==0
              );
void rtc_get_time(unsigned char *hour,unsigned char *min,unsigned char *sec);
void rtc_set_time(unsigned char hour,unsigned char min,unsigned char sec);
void rtc_get_date(unsigned char *date,unsigned char *month,unsigned char *year);
void rtc_set_date(unsigned char date,unsigned char month,unsigned char year);

#include "ds1307.c"



#endif
