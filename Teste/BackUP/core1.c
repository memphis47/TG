#include "../include/cMIPS.h"
#include "cLupa.h"

unsigned int *img;
unsigned int *mem;

unsigned int zoomCfg;
unsigned int contrastecfg;

int main(void) {
  unsigned int bcd_max = BCDCapacity;

  unsigned framestream = 0; // Números de frames a executar

  unsigned int dma_t_ok; // Transferência RAM para DMA_VGA finalizado em 0

  unsigned int pixel;       // pixel lido da RAM

  unsigned int l, c;        // indexadores de linhas e colunas

  // Divide por 4 pois ponteiro é por palavra (?)
  img = (int*) dataImgAddressI/4;
  
  for (framestream = 0; framestream < frameStream; framestream++){

    readInt(&zoomCfg);
    readInt(&contrastecfg);


    if (zoomCfg == ZINACTIVE) { // Zoom inativo

        // escrita em memória sem ZOOM
		    for(l = 0; l < totalPixelImagem; l++){
		        bcd_max = bcdRSt();         
		        while(bcd_max <= 0){  // pooling?
		          bcd_max = bcdRSt();
		        }  

		        // leitura do buffer
		        pixel = bcdRRd();
		        
		        // escrita em memória
		        mem = img + l;
		        *mem = (int) pixel;
          }

    } else {                    // Zoom Ativo

      for(l = 0; l < alturaImagem; l++){
        for(c = 0; c < larguraImagem; c++){

            bcd_max = bcdRSt();         
            while(bcd_max <= 0){  // pooling?
              bcd_max = bcdRSt();
            }       

            // leitura do buffer
            pixel = bcdRRd();        

            // Replica para posição original
            mem = img + l*larguraImagem + c;
            *mem = (int) pixel;

            // Replica para posição original+1
            mem = img + l*larguraImagem + (c+1);
            *mem = (int) pixel;
          
            // Replica para próxima linha na posição original
            mem = img + (l+1)*larguraImagem + c;
            *mem = (int) pixel;

            // Replica para próxima linha na posição original+1
            mem = img + (l+1)*larguraImagem + (c+1);
            *mem = (int) pixel;

            c++;
        }
        l++;
      }

    } // if (zoomCfg == ZINACTIVE) else

    // Envio para VGA
  //  dmaVGA_init(a, w, s);
    dmaVGA_init(dataImgAddressI, 4, totalPixelImagem);
    dma_t_ok = dmaVGA_st();
    while(dma_t_ok != 0){
      dma_t_ok = dmaVGA_st();
    }

  } // for (framestream = 0; framestream < frameStream; framestream++){

  dmaVGA_closeFile();

//  while(1){
    // dumb core
//  }

  return 0;
}
