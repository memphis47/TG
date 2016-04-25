#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 10;

int fibonacci(int i) {
	if (i <= 1)
		return i;
	else
		return fibonacci(i-1) + fibonacci(i-2);
}

int main(void) {

	unsigned int bcd_max = 0; // Capacidade inicial BCD


	unsigned int i, j;        // indexadores de linhas e colunas

	for(i=0; i < MAXINT ; i++){
		bcd_max = bcdWSt();
		while(bcd_max == 0){  // pooling
			bcd_max = bcdWSt();
		}
		bcdWWr(fibonacci(i));
	}

	return 0;
}
