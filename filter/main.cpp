#include<stdlib.h>
#include<stdio.h>
#include "filter.h"

int main(int argc, char *argv[])
{
  FILE *fw;
  FILE *fr;
  double* OriginalArray;
  double* FilteredArray;
  const int N = 129;
  const int x0 = (N-1)/2;
  const int y0 = (N-1)/2;
  const int z0 = (N-1)/2;
  const int r = (N-9)/2;
  Filter filter = Filter(box_5pt_approx, 2);
  const int Nf = N-(2*filter.get_filter_ngrow());

  OriginalArray = (double*)calloc(N*N*N,sizeof(double));
  FilteredArray = (double*)calloc(Nf*Nf*Nf,sizeof(double));

  // Create sphere in original 3D domain
  for(int k=0; k<N; k++){
    for(int j=0; j<N; j++){
      for(int i=0; i<N; i++){
        if(((i-x0)*(i-x0)+(j-y0)*(j-y0)+(k-z0)*(k-z0)) < r*r) {
          OriginalArray[(N*N)*k+(N)*j+i] = 1.0;
        }
      }
    }
  }

  // Apply filter to domain
  filter.apply_filter(OriginalArray,FilteredArray,N,Nf);

  /*//Print out original and filtered array to read in visit
  for(int k=0; k<Nf; k++){
    for(int j=0; j<Nf; j++){
      for(int i=0; i<Nf; i++){
        printf("%d,%d,%d,%f,%f\n",i,j,k,FilteredArray[(Nf*Nf)*k+(Nf)*j+i],OriginalArray[(N*N)*(k+filter.get_filter_ngrow())+(N)*(j+filter.get_filter_ngrow())+(i+filter.get_filter_ngrow())]);
      }
    }
  }*/

  free(OriginalArray);
  free(FilteredArray);

  return 0;
}
