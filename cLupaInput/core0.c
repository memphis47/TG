/*  cLupa 0
      - Alocado em core 0 do cMIPS dual-core
      - Módulo de Contraste e corte de zoom 
        - Se aplicável
*/

#include "cMIPS.h"
#include "cLupa.h"
#include "cLupaContraste.h"

unsigned int totalPixelImg;

unsigned int zoomCfg;
unsigned int contrastecfg;

typedef unsigned int pixel[4];	// ARGB

unsigned int *img;	        // Vetor imagem

int main(void) {
  unsigned int bcd_max = 0; // Capacidade inicial BCD

  unsigned framestream = 0; // Números de frames a executar

  unsigned int dma_t_ok;    // Transferência DMA_USB para RAM finalizado em 0

  unsigned int pixel;       // pixel lido da RAM

  unsigned int l, c;        // indexadores de linhas e colunas

//  unsigned int i;               // iteração do bcd
  unsigned int linha, coluna;
  unsigned int linhaM, colunaM; // Max
  unsigned int sizeL;           // tamanho da linha

  for (framestream = 0; framestream < frameStream; framestream++){

    readInt(&zoomCfg);
    readInt(&contrastecfg);

    // Endereço inicia, Palavras, # palavras
    // inicia transferência DMA -> RAM
    dmaUSB_init(dataImgAddressI, 4, totalPixelImagem);
    
    // Segura cMIPS até transferência finalizar
    // Recomendado utilizar após outras tarefas que não utilizam os dados transferidos
    dma_t_ok = dmaUSB_st();  
    while(dma_t_ok != 0){
      dma_t_ok = dmaUSB_st();  
    } 
      
    // Divide por 4 pois ponteiro é por palavra (?)
    img = (int*) dataImgAddressI/4;

    if (zoomCfg == ZINACTIVE) { // Zoom inativo

		    for(l = 0; l < totalPixelImagem; l++){
            bcd_max = bcdWSt();

            while(bcd_max == 0){  // pooling?
              bcd_max = bcdWSt();
            }

	          pixel = (int) *(img + l); // recupera pixel

            // Aplica contraste
            // Efetua a leitura do vetor imagemBase para imagemCont
            switch(contrastecfg){
	            case CINACTIVE:
			            // Não existe alteração do pixel;
			            break;
	            case CVERMELHO:
			            pixel = contrasteVermelho(pixel);
			            break;
	            case CVERDE:
			            pixel = contrasteVerde(pixel);
			            break;
	            case CCINZA:
			            pixel = contrasteCinza(pixel);
			            break;
            }
    
            // Escrita no BCD
            bcdWWr(pixel);
	    }    

    } else { // if (zoomCfg == ZINACTIVE)
      // Zoom Ativo
      linha   = initialYZoomed;
      coluna  = initialXZoomed;
      linhaM  = finalYZoomed;
      colunaM = finalXZoomed;
      sizeL = larguraImagem;

		  for(l = linha; l < linhaM; l++){
		    for(c = coluna; c < colunaM; c++){      
          bcd_max = bcdWSt();
          while(bcd_max == 0){  // pooling
            bcd_max = bcdWSt();
          }

	        pixel = (int) *(img + l*sizeL + c);

          // Aplica contraste
          // Efetua a leitura do vetor imagemBase para imagemCont
          switch(contrastecfg){
	          case CINACTIVE:
			          // Não existe alteração do pixel;
			          break;
	          case CVERMELHO:
			          pixel = contrasteVermelho(pixel);
			          break;
	          case CVERDE:
			          pixel = contrasteVerde(pixel);
			          break;
	          case CCINZA:
			          pixel = contrasteCinza(pixel);
			          break;
          }

          // Escrita no BCD
          bcdWWr(pixel);

		    } // for(c = coluna; c < colunaM; c++)
	    } // for(l = linha; l < linhaM; l++)

    } // if (zoomCfg == ZINACTIVE) else 

} // for (framestream = 0; framestream < frameStream; framestream++)

  // Segura a execução do cMIPS_0 até cMIPS_1 finalizar
  while(1){
    // dumb core
  }

  return 0;
}
