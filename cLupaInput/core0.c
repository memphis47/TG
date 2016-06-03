#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 312;

int findPrimo(int i){
	int k=0;
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
	return k;
}

int main(void) {

	unsigned int bcd_max = 0; // Capacidade inicial BCD


	unsigned int i, j;        // indexadores de linhas e colunas

	int k;

	k=0;

	while(k < MAXINT){
		bcd_max = bcdWSt();
		print(bcd_max);
		while(bcd_max == 0){  // pooling
			print(12);
			print(bcd_max);
			print(12);
			bcd_max = bcdWSt();
		}
		/*print('-');
		print('-');
		print('-');
		print(bcd_max);
		print('-');
		print('-');
		print('-');*/
		j = findPrimo(k);
		print(10);
		print(j);
		print(10);
		bcdWWr(j);
		k++;
	}

	return 0;
}
