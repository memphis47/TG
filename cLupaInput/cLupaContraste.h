/*  cLupaContraste
      3 funções de aplicação de contraste  
*/

// Pixel
typedef unsigned int Pixel[4];	// ARGB

int contrasteVerde(int j){
	Pixel p;
  int corPixel;
  int r, g, b;

  r = j; g = j; b = j;

  p[RED]   = (unsigned int) ((r>>24) & 0xff);
  p[GREEN] = (unsigned int) ((g>>16) & 0xff);
	p[BLUE]  = (unsigned int) ((b>>8 ) & 0xff);

		// verde é mais sensível
	corPixel = (int)
	  (p[RED] 	 + p[RED] 	+ 
	  p[GREEN] + p[GREEN] + p[GREEN] + 
    p[BLUE]) / 7; 


	p[RED]	 = 0;
	p[GREEN] =(p[GREEN] * corPixel) / 255;
	p[BLUE]	 = 0;

	if(p[GREEN] < 127)
		p[GREEN] = 0;

	j = (p[RED]<<24) | (p[GREEN]<<16) | (p[BLUE]<<8) | 0xff;  // 0xff alfa

  return j;
}

int contrasteVermelho(int j){
	Pixel p;
  int corPixel;
  int r, g, b;

  r = j; g = j; b = j;

  p[RED]   = (unsigned int) ((r>>24) & 0xff);
  p[GREEN] = (unsigned int) ((g>>16) & 0xff);
	p[BLUE]  = (unsigned int) ((b>>8 ) & 0xff);

	corPixel = (int)
		   (p[RED] 	 + p[RED] 	+ 
				p[GREEN] + p[GREEN] + p[GREEN] + 
				p[BLUE]) / 6; 

	p[RED]	 = (p[RED] * corPixel) / 255;
	p[GREEN] = 0;
	p[BLUE]	 = 0;

	if(p[GREEN] < 127)
		p[GREEN] = 0;

	j = (p[RED]<<24) | (p[GREEN]<<16) | (p[BLUE]<<8) | 0xff;  // 0xff alfa

  return j;
}

int contrasteCinza(int j){
	Pixel p;
  int corPixel;
  int r, g, b;

  r = j; g = j; b = j;

  p[RED]   = (unsigned int) ((r>>24) & 0xff);
  p[GREEN] = (unsigned int) ((g>>16) & 0xff);
	p[BLUE]  = (unsigned int) ((b>>8 ) & 0xff);

	corPixel = p[RED] + p[GREEN] + p[BLUE];
	corPixel = corPixel/3;
	p[RED]   = corPixel;
	p[GREEN] = corPixel;
	p[BLUE]  = corPixel;

	j = (p[RED]<<24) | (p[GREEN]<<16) | (p[BLUE]<<8) | 0xff;  // 0xff alfa

  return j;
}
