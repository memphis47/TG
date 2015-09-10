#ifndef XEAM_H
#define XEAM_H

// Área para variáveis
#define HEAPSIZE 512	

// x_DATA_BASE_ADDR + Heap 
#define dataImgAddressI x_DATA_BASE_ADDR + HEAPSIZE

// alterar para tamanho da imagem a ser tratada
#define larguraImagem		     640
#define alturaImagem 		     480

// alterar para número de frames a executar
#define frameStream         3

#define totalPixelImagem     larguraImagem*alturaImagem

#define larguraZoom          larguraImagem / 2
#define alturaZoom           alturaImagem  / 2
#define initialXZoomed       larguraZoom   / 2 
#define finalXZoomed         larguraZoom   / 2  + larguraZoom  
#define initialYZoomed       alturaZoom    / 2   
#define finalYZoomed         alturaZoom    / 2  + alturaZoom
#define tamanhoImagemZoomed  totalPixelImg / 4

// Zoom
#define ZINACTIVE 0
#define ZACTIVE   1

//#define zoomCfg ZINACTIVE
//#define zoomCfg ZACTIVE

// Contraste
enum contrasteCfg{
	CINACTIVE,	// Contraste desligado  0
	CVERMELHO, 	// Contraste vermelho   1
	CVERDE,		  // Contraste verde      2
	CCINZA		  // Contraste cinza      3
};

// Configuração de Contraste (apenas 1 ativo)
//enum contrasteCfg contrastecfg = CINACTIVE;
//enum contrasteCfg contrastecfg = CVERMELHO;
//enum contrasteCfg contrastecfg = CVERDE;
//enum contrasteCfg contrastecfg = CCINZA;

// Definir com a capacidade do buffer de comunicação
#define BCDCapacity 8

// RGBA
#define	RED		3	// Componente Vermelho
#define GREEN	2	//            Verde
#define BLUE	1	//            Azul
#define ALPHA 0	// Alfa

#endif
