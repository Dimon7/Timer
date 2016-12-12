#ifndef _ds1307_h_
#define _ds1307_h_ 1



void rtc_init(unsigned char PeriodSelect,   // выбор периода на выходе OUT
                                            // 0 - 1 гц
                                            // 1 - 4096 гц
                                            // 2 - 8192 гц
                                            // 3 - 32768 гц
              unsigned char SQWe,           // включение сигнала на выходе OUT
              unsigned char OUTlevel        // уровень на OUT, если SQWe==0
              );
void rtc_get_time(unsigned char *hour,unsigned char *min,unsigned char *sec);
void rtc_set_time(unsigned char hour,unsigned char min,unsigned char sec);
void rtc_get_date(unsigned char *date,unsigned char *month,unsigned char *year);
void rtc_set_date(unsigned char date,unsigned char month,unsigned char year);

#include "ds1307.c"



#endif
