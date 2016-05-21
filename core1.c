#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 10;

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

	unsigned int bcd_max = 0; // Capacidade inicial BCD


	unsigned int i, received;        // indexadores de linhas e colunas

	for(i=0; i < MAXINT ; i++){
		bcd_max = bcdRSt();         
        while(bcd_max <= 0){  // pooling?
          bcd_max = bcdRSt();
        }  

        // leitura do buffer
        received = bcdRRd();
		primo(received);
	}

	return 0;
}
