#include<stdlib.h>
#include<stdio.h>
#include<cmath>
#include "filter.h"

int main(int argc, char *argv[])
{
  FILE *fw;
  FILE *fr;
  double* OriginalArray;
  double* FilteredArray;
  const int N = 65;
  const int x0 = (N-1)/2;
  const int y0 = (N-1)/2;
  const int z0 = (N-1)/2;
  const int r = (N-9)/2;
  const int filter_type = box_3pt_approx;
  Filter filter = Filter(filter_type, 2);
  const int Nf = N-(2*filter.get_filter_ngrow());
  double norm = 0.0;
  const double goldNorm5pt = 297.9187131508175526;
  const double goldNorm3pt = 298.0234308968230152;
  const double tol = 1e-15;
  double goldNorm;

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

  // Verify results
  for(int i=0; i < Nf*Nf*Nf; i++){
    norm += FilteredArray[i] * FilteredArray[i];
  }
  norm = sqrt(norm);
  //printf("%.16f\n",norm);

  free(OriginalArray);
  free(FilteredArray);

  if(filter_type == box_5pt_approx){
    goldNorm = goldNorm5pt;
  } else if(filter_type == box_3pt_approx){
    goldNorm = goldNorm3pt;
  }

  if(abs(norm-goldNorm) < tol){
    printf("Success.\n");
    return 0;
  } else {
    printf("Fail.\n");
    return 1;
  }
}
