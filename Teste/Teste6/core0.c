#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 48;

int main(void) {

	int j,k;
	k = 0;
	j = 0;
	while(k < MAXINT){
	    
		

		int i = k;
		while(i < 1836311903){
			int divisor = 2;
			int ehPrimo = 1;		/* Verificador de primo */

			if (i <= 2)
			  ehPrimo = 0;

			while (ehPrimo == 1 && divisor <= i / 2) {
				if (i % divisor == 0)
					ehPrimo = 0;
				divisor++;
			}
			if(ehPrimo==1 && i!=j && i>j){
				j = i ;
				break;
			}
			i++;
		}

		print(j);
		k++;
	}

	return 0;
}
