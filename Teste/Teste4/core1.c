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

int main(void) {

	unsigned int bcd_max = 0; // Castatic int const MAXINT = 312;pacidade inicial BCD


	unsigned int i, received;        // indexadores de linhas e colunas

	int k;

	k = 0 ;

	while(k < MAXINT){
		bcd_max = bcdRSt();
		print(bcd_max);
        while(bcd_max == 0){  // pooling?
		  print(bcd_max);
          bcd_max = bcdRSt();
        }
        received = bcdRRd();
		primo(received);
		k++;
	}

	return 0;
}
