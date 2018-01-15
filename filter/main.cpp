#include<stdlib.h>
#include<stdio.h>
#include "filter.h"

int main(int argc, char *argv[])
{
  FILE *fw;
  FILE *fr;
  double* OriginalArray;
  double* ReadArray;
  double* FilteredArray;
  const int x0=16;
  const int y0=16;
  const int z0=16;
  const int r=16;
  const int N=33;
  Filter filter = Filter(box_5pt_approx, 2);
  const int Nf=N-(2*filter.get_filter_ngrow());

  OriginalArray = (double*)malloc(N*N*N*sizeof(double));
  ReadArray = (double*)malloc(N*N*N*sizeof(double));
  FilteredArray = (double*)malloc(Nf*Nf*Nf*sizeof(double));

  for(int k=0; k<N; k++){
    for(int j=0; j<N; j++){
      for(int i=0; i<N; i++){
        if(((i-x0)*(i-x0)+(j-y0)*(j-y0)+(k-z0)*(k-z0)) < r*r) {
          OriginalArray[(N*N)*k+(N)*j+i] = 1;
        } else {
          OriginalArray[(N*N)*k+(N)*j+i] = 0;
        }
        //printf("%f ",OriginalArray[(N*N)*k+(N)*j+i]);
      }
      //printf("\n");
    }
    //printf("\n");
  }

  fw = fopen("test.bin","wb");
  fwrite(OriginalArray,sizeof(double),N*N*N,fw);
  fclose(fw);

  fr = fopen("test.bin","rb");
  fread(ReadArray,sizeof(double),N*N*N,fr);
  fclose(fr);

  filter.apply_filter(OriginalArray,FilteredArray,N,Nf);

  for(int k=0; k<Nf; k++){
    for(int j=0; j<Nf; j++){
      for(int i=0; i<Nf; i++){
        printf("%d,%d,%d,%f,%f\n",i,j,k,FilteredArray[(Nf*Nf)*k+(Nf)*j+i],OriginalArray[(N*N)*(k+filter.get_filter_ngrow())+(N)*(j+filter.get_filter_ngrow())+(i+filter.get_filter_ngrow())]);
      }
      //printf("\n");
    }
    //pdrintf("\n");
  }
         
  free(OriginalArray);
  free(ReadArray);
  free(FilteredArray);

  return 0;
}
