#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 48;


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

	int j,k;
	k = 0;
	volatile unsigned int bcd_max_aux;
	j = 0;
	while(k < MAXINT){
	    
		int old = clkcount();
   
		do{
			bcd_max_aux = bcdWSt();
		}while(bcd_max_aux<=0);
		
		print( clkcount() - old );

		int i = k;
		while(i < 1836311903){
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
