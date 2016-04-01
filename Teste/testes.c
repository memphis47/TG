#include "../include/cMIPS.h"
#include "cLupa.h"

/* CORE 0 */
int int main(int argc, char const *argv[])
{
	unsigned int bcd_max = 0;
	int n;
	// max eh a potencia que de n
	for(int i = 0; i < max ; i++){
		bcd_max = bcdWSt();
		while(bcd_max == 0){  // pooling
			bcd_max = bcdWSt();
		}
		n*=n;
		bcdWWr(n);
	}
	return 0;
}
/*----------------------------------------------*/
/* CORE 1 */
int progAri(int max){
	int n = 0;
	for(int i = 1; i <= max ; i++){
		n += i;
	}
	return n;
}

int main(int argc, char const *argv[])
{
	int n;
	// max eh a potencia que de n
	for(int i = 0; i < max ; i++){
		bcd_max = bcdRSt();         
        while(bcd_max <= 0){  // pooling?
          bcd_max = bcdRSt();
        }  

        // leitura do buffer
        received = bcdRRd();
		progAri(received);
	}
	return 0;
}
/*----------------------------------------------*/
/* CORE 0 */
static int const MAXINT = 200;

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
		bcd_max = bcdWSt();         
        while(bcd_max <= 0){  // pooling?
          bcd_max = bcdWSt();
        }  
		bcdWWr(primo(received))
	}

	return 0;
}