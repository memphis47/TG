/*  
    decoderImgData:	decodificador vga.data
      Usado para gerar as imagens resultantes da simulação XeamDual com DMA-USB e VGA Emulados
    data: 21/11/2014

    Cria arquivos img#.bmp 

    Funcionamento
      Recupera as imagens gravadas em img.data (coderImgData) pós-processadas e salvas em vga.data

    Uso:
      ./decoderImgData

    Condições:
      O arquivo vga.data é requerido e deve estar no diretório atual
      O arquivo img.head é requerido e deve estar no diretório atual

    Saídas:
      img####.bmp : Arquivos de imagem com cabeçalho replicado

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define imgFile "img"
#define imgExte ".bmp"
#define imgData "vga.data"
#define imgHead "img.head"

FILE *imgFileH;
FILE *imgDataH;
FILE *imgHeadH;

int main(int argc, char *argv[]){

  int  numImagens;
  int  numImgName = 0;
  char numImgNameTemp[255];

  int i;

  char nomeFiles[255];

  int  sizeHeader;
  int  sizeImg;

  int *header;
  int *imgVetor;

	struct stat st;
/*
	// teste de entrada
	if(argc < 2){
		printf("Lista de argumentos incorretos\n");
		printf("Execução:\t%s #imagens\n", argv[0]);
		exit(-1);
  } else {
      if (atoi(argv[1]) != 0){
        numImagens = atoi(argv[1]);
      } else {
		    printf("Lista de argumentos incorretos\n");
    		printf("Execução:\t%s #imagens\n", argv[0]);
        printf("\t\tO campo #imagens é obrigatóriamente um número\n");
        exit(-1);
      }
  }
*/
  imgDataH = fopen(imgData, "r");
	if(!imgDataH){
		printf("Não foi possível abrir \"%s\" para leitura\n", imgData);
		printf("\tVerificar espaço em disco/permissões\n");
		printf("Encerrado!\n");
    exit(-1);
	}

  imgHeadH = fopen(imgHead, "r");
	if(!imgHeadH){
		printf("Não foi possível abrir \"%s\" para leitura\n", imgHead);
		printf("\tVerificar espaço em disco/permissões\n");
		printf("Encerrado!\n");
    exit(-1);
	}

  // Recuperação do tamanho da imagem original
  fseek(imgHeadH, 2, SEEK_SET);
  fread(&sizeImg, sizeof(int), 1, imgHeadH);

  // Arquivo de cabeçalho
  rewind(imgHeadH);

  // size do header
	stat(imgHead, &st);
  sizeHeader = (int) st.st_size;

  // copia do header
  header = (int*) calloc(sizeHeader, sizeof(char));
	if(header == NULL){
		printf("Problemas de alocação\n\t: \"header\"\n");
		exit(-1);
	}
	fread( header, sizeof(char), sizeHeader, imgHeadH);

  sizeImg = sizeImg - sizeHeader;
  
  // Calculo de quantidade de imagens em vga.data
  // tamanho do arquivo vga.data
 	stat(imgData, &st);
  // divisão pelo tamanho da imagem original
  numImagens = (int) st.st_size / sizeImg;

  printf("# imagens encontradas: %d \n",numImagens);

  // alocação do vetor imagem
  imgVetor = (int*) calloc(sizeImg, sizeof(char));
	if(imgVetor == NULL){
		printf("Problemas de alocação\n\t: \"imgVetor\"\n");
		exit(-1);
	}

  // laço de repetição
  for(i = 0; i < numImagens; i++){

    strcpy(nomeFiles,imgFile);
    sprintf(numImgNameTemp, "%04d", numImgName);
    strcat(nomeFiles,numImgNameTemp);
    strcat(nomeFiles,imgExte);

	  imgFileH = fopen(nomeFiles,  "w+");
	  if(!imgFileH){
		  printf("Não foi possível abrir \"%s\" para escrita\n", nomeFiles);
		  printf("\tVerificar espaço em disco/permissões\n");
		  printf("Encerrado!\n");
      exit(-1);
	  }
  
    // copia do vetor de imagem n 
    fread( imgVetor, sizeof(int), sizeImg/4, imgDataH);

    // escrita do header
    fwrite(header, sizeof(char), sizeHeader, imgFileH);

    // escrita do vetor de imagem n
    fwrite(imgVetor, sizeof(int), sizeImg/4, imgFileH);

    fclose(imgFileH);
  
  printf("Escrita de %s completada\n", nomeFiles);

  // laço de repeticao
    numImgName++;
  }

	fclose(imgDataH);
  fclose(imgHeadH);

  printf("Decodificação finalizada com %d imagens recuperadas\n", numImagens);

	exit(0);
}
