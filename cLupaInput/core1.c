#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 48;



int main(void) {

	int received,k;

	k = 0 ;

	while(k < MAXINT){
		int bcd_max_aux;
		do{
        	bcd_max_aux =(int) bcdRSt();
        	//print(12);
			//print(bcd_max_aux);
			//print(13);
		}while(bcd_max_aux == 0);

		print(15);
        received = bcdRRd();
		int divisor = 2;
		int ehPrimo = 1;		/* Verificador de primo */

		if (received <= 2)
		ehPrimo = 0;

		while (ehPrimo == 1 && divisor <= received/ 2) {
			if (received % divisor == 0)
				ehPrimo = 0;
			divisor++;
		}
		k++;
	}

	return 0;
}
