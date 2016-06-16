#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 48;

int findPrimo(int i){
	print(i);
	int k;
	k = 0;
	print(k);
	while(k < i){
		print(k);
		int divisor = 2;
		int ehPrimo = 1;		/* Verificador de primo */

		if (k <= 2)
		  ehPrimo = 0;

		while (ehPrimo == 1 && divisor <= k / 2) {
			if (k % divisor == 0)
				ehPrimo = 0;
			divisor++;
		}
		if(ehPrimo==1)
			return k;
		k++;
	}
	print(k);
	return k;
}

int main(void) {

	int j,k;
	k = 0;
	volatile unsigned int bcd_max_aux;
	j = 0;
	while(k < MAXINT){
	    
		do{
			bcd_max_aux = bcdWSt();
		}while(bcd_max_aux<=0);

		int i = k;
		while(i < MAXINT){
			print(i);
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
		bcdWWr(j);
		k++;
	}

	return 0;
}
