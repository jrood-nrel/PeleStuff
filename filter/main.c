#define N 33
#include<stdlib.h>
#include<stdio.h>

int main(int argc, char *argv[])
{
  FILE *fw;
  FILE *fr;
  double* Q;
  double* R;
  const int x0=16;
  const int y0=16;
  const int z0=16;
  const int r=16;

  Q = (double*)malloc(N*N*N*sizeof(double));
  R = (double*)malloc(N*N*N*sizeof(double));

  for(int k=0; k<N; k++){
    for(int j=0; j<N; j++){
      for(int i=0; i<N; i++){
        if(((i-x0)*(i-x0)+(j-y0)*(j-y0)+(k-z0)*(k-z0)) < r*r) {
          Q[(N*N)*k+(N)*j+i] = 0;
        } else {
          Q[(N*N)*k+(N)*j+i] = 1;
        }
        //printf("%f ",Q[(N*N)*k+(N)*j+i]);
      }
      //printf("\n");
    }
    //printf("\n");
  }

  fw = fopen("test.bin","wb");
  fwrite(Q,sizeof(double),N*N*N,fw);
  fclose(fw);

  fr = fopen("test.bin","rb");
  fread(R,sizeof(double),N*N*N,fr);
  fclose(fr);

  for(int k=0; k<N; k++){
    for(int j=0; j<N; j++){
      for(int i=0; i<N; i++){
        printf("%d ",(int)R[(N*N)*k+(N)*j+i]);
      }
      printf("\n");
    }
    printf("\n");
  }

  free(Q);
  free(R);

  return 0;
}
