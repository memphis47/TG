#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 312;


int primo(int i) {
	int divisor = 2;
    int ehPrimo = 1;		/* Verificador de primo */

    if (i <= 2)
	  ehPrimo = 0;

    while (ehPrimo == 1 && divisor <= i / 2) {
		if (i % divisor == 0)
			ehPrimo = 0;
		divisor++;
    }
	
	return ehPrimo;
}

int findPrimo(int i){
	int k=0;
	while(k < i){
		if(primo(k) == 1)
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
			print(bcd_max);
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
		bcdWWr(j);
		k++;
	}

	return 0;
}
