#include "../include/cMIPS.h"
#include "cLupa.h"
#define RAND_MAX 60
#define LCD_delay_30us   750/4     //  30us / 20ns



int main(void) {

	int received;
	unsigned int temp;
	unsigned int m_w = 101;    /* must not be zero, nor 0x464fffff */
	unsigned int m_z = 311; 

	while(1){
		int bcd_max_aux;
		do{
        	bcd_max_aux =(int) bcdRSt();
		}while(bcd_max_aux == 0);

        received = bcdRRd();
        //print(received);

        m_z = 36969 * (m_z & 65535) + (m_z >> 16);
		m_w = 18000 * (m_w & 65535) + (m_w >> 16);
		temp =  ((m_z << 16) + m_w) & 255;

		if((LCD_delay_30us * temp) ==  0)
			temp = 1;
		print(LCD_delay_30us * temp);
		cmips_delay(LCD_delay_30us * temp);
	}

	return 0;
}
