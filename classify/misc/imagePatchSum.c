/* imagePatchSum.cpp
 *   [c_sum, c_count] = imagePatchSum(raw, cfa, patchSz)
 *
 * Compute channel sum and count of each patch
 *
 * HJ, VISTA TEAM, 2015
 */

#include "mex.h"
#include <math.h>

/* the gateway routine */
void mexFunction(int nlhs, mxArray *plhs [],
        int nrhs, const mxArray *prhs[]) {
    // Check inputs
    if (nrhs != 3) mexErrMsgTxt("Invalid number of inputs");
    
    // Get raw data
    if (!mxIsDouble(prhs[0])) mexErrMsgTxt("raw should be in double");
    mwSize nrows = mxGetM(prhs[0]);
    mwSize ncols = mxGetN(prhs[0]);
    double *raw = mxGetPr(prhs[0]);
    
    // Get cfa
    if (!mxIsDouble(prhs[1])) mexErrMsgTxt("cfa should be in double");
    mwSize cfaR = mxGetM(prhs[1]);
    mwSize cfaC = mxGetN(prhs[1]);
    
    int *cfa = mxMalloc(cfaR*cfaC*sizeof(int));
    for (int i = 0; i < cfaR*cfaC; i++) cfa[i] = i;
    
    // Get patch size
    if (!mxIsDouble(prhs[2])) mexErrMsgTxt("patch size should be double");
    double *patchSz = mxGetPr(prhs[2]);
    
    // Allocate output matrix size
    int nC = cfaR * cfaC; // number of channels
    
    mwSize pm[3] = {nrows-(int)patchSz[0]+1, ncols-(int)patchSz[1]+1, nC};
    plhs[0] = mxCreateNumericArray(3, pm, mxDOUBLE_CLASS, mxREAL);
    double *cSum = mxGetPr(plhs[0]);
    
    double* cRaw = mxMalloc(nrows*ncols*nC*sizeof(double));
    
    // Compute cumulative sum in columns
    for (int i=0; i<ncols; i++) { // init first row
        int cfa_indx = cfa[cfaR*(i%cfaC)];
        cRaw[i*nrows + cfa_indx*nrows*ncols] = raw[i*nrows];
    }
    for (int i=0; i<ncols; i++) {
        for (int j=1; j<nrows; j++){
            for (int k=0; k<nC; k++){
                int indx = j + i*nrows + k*nrows*ncols;
                cRaw[indx] = cRaw[indx-1];
            }
            int cfa_indx = cfa[j%cfaR + cfaR * (i%cfaC)];
            cRaw[j+i*nrows+cfa_indx*nrows*ncols] += raw[j+i*nrows];
        }
    }
    
    // Compute cumulative sum in rows
    for (int i=1; i<ncols; i++) {
        for (int j=0; j<nrows; j++) {
            for (int k=0; k<nC; k++) {
                int indx = j + i*nrows + k*nrows*ncols;
                cRaw[indx] += cRaw[indx-nrows];
            }
        }
    }
    
    // Compute channel sum and count for each patch
    for (int k=0; k<nC; k++) {
        for (int i=0; i<pm[1]; i++) {
            for (int j=0; j<pm[0]; j++) {
                int indx = j+patchSz[0]-1 + nrows*(i+patchSz[1]-1) +
                        k*nrows*ncols;
                int outIndx = j+i*pm[0]+k*pm[0]*pm[1];
                cSum[outIndx] = cRaw[indx];
                if (i > 0) {
                    cSum[outIndx] -= cRaw[indx-nrows*(int)patchSz[1]];
                }
                if (j > 0) {
                    cSum[outIndx] -= cRaw[indx-(int)patchSz[0]];
                }
                if (i > 0 && j > 0) {
                    cSum[outIndx]+=cRaw[(int)(indx-patchSz[0]-nrows*patchSz[1])];
                }
            }
        }
    }
    
    if (nlhs < 2) return;
     
    // Compute channel count
    double* cfaCount = mxMalloc(cfaR*cfaC*sizeof(double));
    plhs[1] = mxCreateNumericArray(3, pm, mxDOUBLE_CLASS, mxREAL);
    double *cCount = mxGetPr(plhs[1]);
    
    for (int i=0; i<cfaR; i++){
        for (int j=0; j<cfaC; j++){
            cfaCount[cfa[i+j*cfaR]] = ceil((patchSz[0]-i)/cfaR) *
                    ceil((patchSz[1]-j)/cfaC);
        }
    }
    
    for (int i=0; i<pm[0]; i++) {
        for (int j=0; j<pm[1]; j++) {
            for (int m=0; m<cfaR; m++) {
                for (int n=0; n<cfaC; n++) {
                    int curC = cfa[(i+m)%cfaR+((j+n)%cfaC)*cfaR];
                    cCount[i+j*pm[0]+curC*pm[0]*pm[1]] += cfaCount[m+n*cfaR];
                }
            }
        }
    }
}