#include "../include/cMIPS.h"
#include "cLupa.h"

static int const MAXINT = 48;


/*
http://www.programandoemc.com/2012/05/fibonacci-iterativo.html
*/


int main(void) {

	unsigned int bcd_max_aux; // Capacidade inicial BCD


    int j,k;

	k=0;

	while(k < MAXINT){
		int old = clkcount();
   
		do{
			bcd_max_aux = bcdWSt();
		}while(bcd_max_aux<=0);
		
		print( clkcount() - old );
		

		unsigned int i, l , t;

		i = 1;
		j = 0;

		for (l = 1; l <= k; l++)
		{
			t = i + j;
			i = j;
			j = t;
		}

		bcdWWr(j);
		k++;
	}

	return 0;
}
