#include "../include/cMIPS.h"
#include "cLupa.h"


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

	i = 0 ;

	while(1){
		bcd_max = bcdRSt();         
        while(bcd_max <= 0){  // pooling?
          bcd_max = bcdRSt();
        }  

        // leitura do buffer
        received = bcdRRd();
        print(received);
		print(primo(received));
		i++;
	}

	return 0;
}
