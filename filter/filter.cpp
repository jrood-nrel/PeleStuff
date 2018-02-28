#include<iostream>
#include<cmath>
#include<vector>
#include<chrono>

class Timer
{
public:
    Timer() : beg_(clock_::now()) {}
    void reset() { beg_ = clock_::now(); }
    double elapsed() const { 
        return std::chrono::duration_cast<second_>
            (clock_::now() - beg_).count(); }

private:
    typedef std::chrono::high_resolution_clock clock_;
    typedef std::chrono::duration<double, std::ratio<1> > second_;
    std::chrono::time_point<clock_> beg_;
};

// Filter types
enum filter_types { no_filter = 0,
                    box,                           // 1
                    box_3pt_approx,                // 2
                    box_5pt_approx,                // 3
                    box_3pt_optimized_approx,      // 4
                    box_5pt_optimized_approx,      // 5
                    gaussian_3pt_approx,           // 6
                    gaussian_5pt_approx,           // 7
                    gaussian_3pt_optimized_approx, // 8
                    gaussian_5pt_optimized_approx, // 9
                    num_filter_types};

class Filter
{

public:

  // Default constructor
  Filter (const int type = box,
          const int fgr = 2)
    : _type(type), _fgr(fgr)
  {

    switch(_type) {

    case box:
      set_box_weights();
      break;

    case box_3pt_approx:
    case gaussian_3pt_approx: // same as box_3pt_approx
      set_box_3pt_approx_weights();
      break;

    case box_5pt_approx:
      set_box_5pt_approx_weights();
      break;

    case box_3pt_optimized_approx:
      set_box_3pt_optimized_approx_weights();
      break;

    case box_5pt_optimized_approx:
      set_box_5pt_optimized_approx_weights();
      break;

    case gaussian_5pt_approx:
      set_gaussian_5pt_approx_weights();
      break;

    case gaussian_3pt_optimized_approx:
      set_gaussian_3pt_optimized_approx_weights();
      break;

    case gaussian_5pt_optimized_approx:
      set_gaussian_5pt_optimized_approx_weights();
      break;

    case no_filter:
    default:
      _fgr = 1;
      _ngrow = 0;
      _nweights = 2 *_ngrow + 1;
      _weights.resize(_nweights);
      _weights[0] = 1.;
      break;


    } // end switch

  };

  // Default destructor
  ~Filter () {};

  int get_filter_ngrow(){return _ngrow;};

  void apply_filter(const double* OriginalArray, double* FilteredArray, const int N, const int Nf);

private:
  int _type;
  int _fgr;
  int _ngrow;
  int _nweights;
  std::vector<double> _weights;

  void set_box_weights();

  void set_box_3pt_approx_weights();

  void set_box_5pt_approx_weights();

  void set_box_3pt_optimized_approx_weights();

  void set_box_5pt_optimized_approx_weights();

  void set_gaussian_5pt_approx_weights();

  void set_gaussian_3pt_optimized_approx_weights();

  void set_gaussian_5pt_optimized_approx_weights();

};

/**
 * Set the filter weights for the standard box filter
 **/
void Filter::set_box_weights(){

  _ngrow = _fgr / 2;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  // Set the weights
  for(int i=0; i<_nweights; i++){
    _weights[i] = 1.0 / _fgr;
  }

  // Only half the cell is used at the ends
  _weights[0] = 0.5*_weights[0];
  _weights[_nweights-1] = _weights[0];
}

/**
 * Set the filter weights for the 3pt polynomial truncation
 * approximation of the box filter. See Eq. 26 in Sagaut & Grohens
 * (1999) Int. J. Num. Meth. Fluids.
 **/
void Filter::set_box_3pt_approx_weights(){

  _ngrow = 1;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  // Set the weights
  _weights[0] = _fgr*_fgr / 24.0;
  _weights[1] = (12.0 - _fgr*_fgr) / 12.0;
  _weights[2] = _weights[0];
}

/**
 * Set the filter weights for the 5pt polynomial truncation
 * approximation of the box filter. See Eq. 27 in Sagaut & Grohens
 * (1999) Int. J. Num. Meth. Fluids (though there are typos).
 **/
void Filter::set_box_5pt_approx_weights(){

  _ngrow = 2;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  // Set the weights
  int _fgr2 = _fgr*_fgr;
  int _fgr4 = _fgr2*_fgr2;
  _weights[0] = (3.0*_fgr4 - 20.0*_fgr2) / 5760.0;
  _weights[1] = (80.0*_fgr2 - 3.0*_fgr4) / 1440.0;
  _weights[2] = (3.0*_fgr4 - 100.0*_fgr2 + 960.0) / 960.0;
  _weights[3] = _weights[1];
  _weights[4] = _weights[0];
}

/**
 * Set the filter weights for the 3pt optimized approximation of the
 * box filter. See Table I in Sagaut & Grohens (1999)
 * Int. J. Num. Meth. Fluids.
 **/
void Filter::set_box_3pt_optimized_approx_weights(){

  _ngrow = 1;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  double ratio;
  switch(_fgr) {

  case 1:
    ratio = 0.079;
    break;

  case 2:
    ratio = 0.274;
    break;

  case 3:
    ratio = 1.377;
    break;

  case 4:
    ratio = -2.375;
    break;

  case 5:
    ratio = -1.000;
    break;

  case 6:
    ratio = -0.779;
    break;

  case 7:
    ratio = -0.680;
    break;

  case 8:
    ratio = -0.627;
    break;

  case 9:
    ratio = -0.596;
    break;

  case 10:
    ratio = -0.575;
    break;

  default: // default to standard box filter
    set_box_weights();
    return;
    break;

  } // end switch

  // Set the weights
  _weights[0] = ratio / (1+2.0*ratio);
  _weights[1] = 1.0 - 2.0*_weights[0];
  _weights[2] = _weights[0];
}

/**
 * Set the filter weights for the 5pt optimized approximation of the
 * box filter. See Table I in Sagaut & Grohens (1999)
 * Int. J. Num. Meth. Fluids.
 **/
void Filter::set_box_5pt_optimized_approx_weights(){

  _ngrow = 2;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  double ratio1;
  double ratio2;
  switch(_fgr) {

  case 1:
    ratio1 = 0.0886;
    ratio2 = -0.0169;
    break;

  case 2:
    ratio1 = 0.3178;
    ratio2 = -0.0130;
    break;

  case 3:
    ratio1 = 1.0237;
    ratio2 = 0.0368;
    break;

  case 4:
    ratio1 = 2.4414;
    ratio2 = 0.5559;
    break;

  case 5:
    ratio1 = 0.2949;
    ratio2 = 0.7096;
    break;

  case 6:
    ratio1 = -0.5276;
    ratio2 = 0.4437;
    break;

  case 7:
    ratio1 = -0.6708;
    ratio2 = 0.3302;
    break;

  case 8:
    ratio1 = -0.7003;
    ratio2 = 0.2767;
    break;

  case 9:
    ratio1 = -0.7077;
    ratio2 = 0.2532;
    break;

  case 10:
    ratio1 = -0.6996;
    ratio2 = 0.2222;
    break;

  default: // default to standard box filter
    set_box_weights();
    return;
    break;

  } // end switch

  // Set the weights
  _weights[0] = ratio2 / (1+2.0*ratio1+2.0*ratio2);
  _weights[1] = ratio1 / ratio2 * _weights[0];
  _weights[2] = 1.0 - 2.0*_weights[0] - 2.0*_weights[1];
  _weights[3] = _weights[1];
  _weights[4] = _weights[0];
}

/**
 * Set the filter weights for the 5pt polynomial truncation
 * approximation of the gaussian filter. See Eq. 29 in Sagaut &
 * Grohens (1999) Int. J. Num. Meth. Fluids.
 **/
void Filter::set_gaussian_5pt_approx_weights(){

  _ngrow = 2;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  // Set the weights
  int _fgr2 = _fgr*_fgr;
  int _fgr4 = _fgr2*_fgr2;
  _weights[0] = (_fgr4 - 4.0*_fgr2) / 1152.0;
  _weights[1] = (16.0*_fgr2 - _fgr4) / 288.0;
  _weights[2] = (_fgr4 - 20.0*_fgr2 + 192.0) / 192.0;
  _weights[3] = _weights[1];
  _weights[4] = _weights[0];
}

/**
 * Set the filter weights for the 3pt optimized approximation of the
 * gaussian filter. See Table I in Sagaut & Grohens (1999)
 * Int. J. Num. Meth. Fluids.
 **/
void Filter::set_gaussian_3pt_optimized_approx_weights(){

  _ngrow = 1;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  double ratio;
  switch(_fgr) {

  case 1:
    ratio = 0.0763;
    break;

  case 2:
    ratio = 0.2527;
    break;

  case 3:
    ratio = 1.1160;
    break;

  case 4:
    ratio = -3.144;
    break;

  case 5:
    ratio = -1.102;
    break;

  case 6:
    ratio = -0.809;
    break;

  case 7:
    ratio = -0.696;
    break;

  case 8:
    ratio = -0.638;
    break;

  case 9:
    ratio = -0.604;
    break;

  case 10:
    ratio = -0.581;
    break;

  default: // default to the 3pt gaussian filter
    set_box_3pt_approx_weights();
    return;
    break;

  } // end switch

  // Set the weights
  _weights[0] = ratio / (1+2.0*ratio);
  _weights[1] = 1.0 - 2.0*_weights[0];
  _weights[2] = _weights[0];
}

/**
 * Set the filter weights for the 5pt optimized approximation of the
 * gaussian filter. See Table I in Sagaut & Grohens (1999)
 * Int. J. Num. Meth. Fluids.
 **/
void Filter::set_gaussian_5pt_optimized_approx_weights(){

  _ngrow = 2;
  _nweights = 2 * _ngrow + 1;
  _weights.resize(_nweights);

  double ratio1;
  double ratio2;
  switch(_fgr) {

  case 1:
    ratio1 = 0.0871;
    ratio2 = -0.0175;
    break;

  case 2:
    ratio1 = 0.2596;
    ratio2 = -0.0021;
    break;

  case 3:
    ratio1 = 0.4740;
    ratio2 = 0.0785;
    break;

  case 4:
    ratio1 = 0.1036;
    ratio2 = 0.2611;
    break;

  case 5:
    ratio1 = -0.4252;
    ratio2 = 0.3007;
    break;

  case 6:
    ratio1 = -0.6134;
    ratio2 = 0.2696;
    break;

  case 7:
    ratio1 = -0.6679;
    ratio2 = 0.2419;
    break;

  case 8:
    ratio1 = -0.6836;
    ratio2 = 0.2231;
    break;

  case 9:
    ratio1 = -0.6873;
    ratio2 = 0.2103;
    break;

  case 10:
    ratio1 = -0.6870;
    ratio2 = 0.2014;
    break;

  default: // default to 5pt gaussian filter
    set_gaussian_5pt_approx_weights();
    return;
    break;

  } // end switch

  // Set the weights
  _weights[0] = ratio2 / (1+2.0*ratio1+2.0*ratio2);
  _weights[1] = ratio1 / ratio2 * _weights[0];
  _weights[2] = 1.0 - 2.0*_weights[0] - 2.0*_weights[1];
  _weights[3] = _weights[1];
  _weights[4] = _weights[0];
}

/**
 * Run the filtering operation on a MultiFab
 **/
void Filter::apply_filter(const double *OriginalArray, double* FilteredArray, const int N, const int Nf){
/*
  const int tile_size = (Nf-1)/2;
  #pragma omp parallel for
  for(int k = 0; k < Nf; k+=tile_size){
    for(int j = 0; j < Nf; j+=tile_size){
      for(int i = 0; i < Nf; i+=tile_size){
        for(int kk = k; kk < std::min(Nf,k+tile_size); kk++){
          for(int jj = j; jj < std::min(Nf,j+tile_size); jj++){
            for(int ii = i; ii < std::min(Nf,i+tile_size); ii++){
              FilteredArray[(Nf*Nf)*kk+(Nf)*jj+ii] = 0.0;
              for(int n = 0; n < _nweights; n++){
                for(int m = 0; m < _nweights; m++){
                  for(int l = 0; l < _nweights; l++){
                    FilteredArray[(Nf*Nf)*kk+(Nf)*jj+ii] +=
                      _weights[n] * _weights[m] * _weights[l] *
                      OriginalArray[(N*N)*(kk+n)+(N)*(jj+m)+(ii+l)];
                  }
                }
              }
            }
          }
        }
      }
    }
  }
*/
  #pragma omp parallel for collapse(3)
  for(int k = 0; k < Nf; k++){
    for(int j = 0; j < Nf; j++){
      for(int i = 0; i < Nf; i++){
        FilteredArray[(Nf*Nf)*k+(Nf)*j+i] = 0.0;
        for(int n = 0; n < _nweights; n++){
          for(int m = 0; m < _nweights; m++){
            for(int l = 0; l < _nweights; l++){
              FilteredArray[(Nf*Nf)*k+(Nf)*j+i] +=
                _weights[n] * _weights[m] * _weights[l] *
                OriginalArray[(N*N)*(k+n)+(N)*(j+m)+(i+l)];
            }
          }
        }
      }
    }
  }
}

int main(int argc, char *argv[])
{
  double* OriginalArray=NULL;
  double* FilteredArray=NULL;
  const int N = 33;
  const int x0 = (N-1)/2;
  const int y0 = (N-1)/2;
  const int z0 = (N-1)/2;
  const int r = (N-9)/2;
  const int npoints = 7;
  const int fgr = npoints-1;
  const int filter_type = box;
  Filter filter = Filter(filter_type, fgr);
  const int Nf = N-(2*filter.get_filter_ngrow());
  double norm = 0.0;
  const double goldNorm5ptN65 = 297.9187131508175526;
  const double goldNorm3ptN65 = 298.0234308968230152;
  const double goldNorm5ptN257 = 2814.8839319908888683;
  const double goldNorm7ptN33box = 72.9773048862697067;
  const double tol = 1e-15;
  double goldNorm;
  Timer tmr;

  OriginalArray = new double[N*N*N]();
  FilteredArray = new double[Nf*Nf*Nf]();

  // Create sphere in original 3D domain
  for(int k=0; k<N; k++){
    for(int j=0; j<N; j++){
      for(int i=0; i<N; i++){
        if(((i-x0)*(i-x0)+(j-y0)*(j-y0)+(k-z0)*(k-z0)) < r*r) {
          OriginalArray[(N*N)*k+(N)*j+i] = 1.0;
        } else {
          OriginalArray[(N*N)*k+(N)*j+i] = 0.0;
        }
      }
    }
  }

  // Apply filter to domain
  const int iterations = 1000;
  tmr.reset();
  for(int i=0; i<iterations; i++){
    filter.apply_filter(OriginalArray,FilteredArray,N,Nf);
  }
  std::cout << tmr.elapsed()/iterations << " seconds" << std::endl;

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

  delete OriginalArray;
  delete FilteredArray;

  if(filter_type == box_5pt_approx){
    if(N == 65) {
      goldNorm = goldNorm5ptN65;
    } else if (N == 257) {
      goldNorm = goldNorm5ptN257;
    }
  } else if(filter_type == box_3pt_approx){
    goldNorm = goldNorm3ptN65;
  } else if(filter_type == box){
    goldNorm = goldNorm7ptN33box;
  }

  if(std::abs(norm-goldNorm) < tol){
    std::cout << "Success" << std::endl;
    return 0;
  } else {
    std::cout << "Fail" << std::endl;
    return 1;
  }
}
