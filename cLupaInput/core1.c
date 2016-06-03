#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 312;


/*
http://www.programandoemc.com/2012/05/fibonacci-iterativo.html
*/
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

	unsigned int bcd_max = 0; // Castatic int const MAXINT = 312;pacidade inicial BCD


	unsigned int i, received;        // indexadores de linhas e colunas

	int k;

	k = 0 ;

	while(k < MAXINT){
		bcd_max = bcdRSt();
		print(bcd_max);
        while(bcd_max == 0){  // pooling?
        	print(15);
			print(bcd_max);
			print(15);
        	bcd_max = bcdRSt();
        }
        received = bcdRRd();
		int fib = fibonacci(received);
		k++;
	}

	return 0;
}
