#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 48;

//TESTE3 CORE1
int fibonacci(int n) {
	unsigned int i, j, k, t;

	i = 1;
	j = 0;

	for (k = 1; k <= n; k++)
	{
		t = i + j;
		i = j;
		j = t;
	}
	return j;
}

int main(void) {

	int received,k;

	k = 0 ;

	while(k < MAXINT){
		int bcd_max_aux;
		do{
        	bcd_max_aux =(int) bcdRSt();
        	//print(12);
			//print(bcd_max_aux);
			//print(13);
		}while(bcd_max_aux == 0);

		print(15);
        received = bcdRRd();
        print(received);
		int fib = fibonacci(k);
		k++;
	}

	return 0;
}
