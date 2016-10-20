#include "../include/cMIPS.h"
#include "cLupa.h"
#define RAND_MAX 60
#define LCD_delay_30us   750/4     //  30us / 20ns

//http://stackoverflow.com/questions/822323/how-to-generate-a-random-number-in-c
/* Returns an integer in the range [0, n).
 *
 * Uses rand(), and so is affected-by/affects the same seed.
 */

int main(void) {

	unsigned int bcd_max_aux;
	unsigned int temp;
	unsigned int m_w; 
	m_w = 177;    /* must not be zero, nor 0x464fffff */
	unsigned int m_z;
	m_z = 311;    /* must not be zero, nor 0x9068ffff */
	while(1){
		do{
			bcd_max_aux = bcdWSt();
		}while(bcd_max_aux <=  0);
		m_z = 36969 * (m_z & 65535) + (m_z >> 16);
		m_w = 18000 * (m_w & 65535) + (m_w >> 16);
		temp =  ((m_z << 16) + m_w) & 255;
		
		cmips_delay(LCD_delay_30us * temp);
		
		bcdWWr(LCD_delay_30us * temp);
	}

	return 0;
}
