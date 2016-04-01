/*  
    coderImgData:	codificador img.data
      Usado para gerar o img.data para simulação XeamDual com DMA-USB Emulado
    data: 20/11/2014

    Cria um arquivo img.data que deve ser adicionado no diretório raiz do cMIPS-XeamDual-DMA-USB

    Funcionamento
      Copia o vetor imagem (bmp 32bits) de um aquivo para img.data

    Uso:
      ./coderImgData bmp32bits1 #copias [bmp32bits2 #copias ] ... [bmp32bitsN #copias ]
      bmp32bits1 : requerido
      [#copias]  : replicação

    Saídas:
      img.data: Arquivo contendo multiplos vetores de imagens
      img.head: Cabeçalho da primeira imagem (genérico)

  IMPORTANTE: Multiplos arquivos não está implementado 20/11/2014
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define imgData "img.data"
#define imgHead "img.head"

FILE *imgFileH;
FILE *imgDataH;
FILE *imgHeadH;

typedef struct imgCp{
	char imgFile[255];
  unsigned int cp;
}imgCp;

imgCp ic;

int main(int argc, char *argv[]){
  
  int n;
  //imgCp *list;

	struct stat st;

  int deslocVetor;  // Deslocamento para inicio do vetor de imagem
  int *header;      // Cabeçalho bmp
  int *imgVetor;    // Vetor de imagem

//  char assinaturaBMP[2];

	// teste de entrada
	if(argc < 3){
		printf("Lista de argumentos incorretos\n");
		printf("Execução:\t%s bmp32bitsFile #copias\n", argv[0]);
		exit(-1);
  } else {
    memcpy(ic.imgFile, argv[1], 255);
    if (atoi(argv[2]) != 0){
      ic.cp = atoi(argv[2]);
    } else {
		  printf("Lista de argumentos incorretos\n");
  		printf("Execução:\t%s bmp32bitsFile #copias\n", argv[0]);
      printf("\t\tO campo #copias é obrigatóriamente um número\n");
      exit(-1);
    } // else atoi(argv[2])

    printf("Arquivo %s será copiado %dx em %s\n", ic.imgFile, ic.cp, imgData);

  } // else argc < 3

  imgFileH = fopen(ic.imgFile, "r");
	if(!imgFileH){
		printf("Não foi possível abrir \"%s\" para leitura\n", ic.imgFile);
		printf("\tVerificar espaço em disco/permissões\n");
		printf("Encerrado!\n");
    exit(-1);
	}

	imgDataH = fopen(imgData,  "w+");
	if(!imgDataH){
		printf("Não foi possível abrir \"%s\" para escrita\n", imgData);
		printf("\tVerificar espaço em disco/permissões\n");
		printf("Encerrado!\n");
    exit(-1);
	}

	imgHeadH = fopen(imgHead,  "w+");
	if(!imgHeadH){
		printf("Não foi possível abrir \"%s\" para escrita\n", imgHead);
		printf("\tVerificar espaço em disco/permissões\n");
		printf("Encerrado!\n");
    exit(-1);
	}

	stat(ic.imgFile, &st);
	int size = (int) st.st_size - 138;
  printf("Tamanho de cada imagem: %d\n",size);
  printf("# pixels de cada imagem: %d\n",size/4);

  // ler deslocamento
  fseek(imgFileH, 10, SEEK_SET);
	fread( &deslocVetor, sizeof(int), 1, imgFileH);
  printf("Deslocamento: %d\n",deslocVetor);

  // Arquivo de cabeçalho
  rewind(imgFileH);
    
  header = (int*) calloc(deslocVetor, sizeof(char));
	if(header == NULL){
		printf("Problemas de alocação\n\t: \"header\"\n");
		exit(-1);
	}

  // Leitura do cabeçalho
	fread( header, sizeof(char), deslocVetor, imgFileH);

  // Gravação do cabeçalho
  fwrite(header, sizeof(char), deslocVetor, imgHeadH);

  printf("Cabeçalho salvo em %s\n", imgHead);
  
  // Para vetor
  fseek(imgFileH, deslocVetor, SEEK_SET);

  imgVetor = (int*) calloc(size/4, sizeof(int));
	if(imgVetor == NULL){
		printf("Problemas de alocação\n\t: \"imgVetor\"\n");
		exit(-1);
	}

  // Leitura do Vetor
	fread( imgVetor, sizeof(int), size/4, imgFileH);

  // Gravar arquivo n vezes
  for(n = 0; n < ic.cp; n++){
  	fwrite(imgVetor, sizeof(int), size/4, imgDataH);
  }

	fclose(imgFileH);
  fclose(imgHeadH);
	fclose(imgDataH);

	exit(0);
}
