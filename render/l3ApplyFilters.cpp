/* Apply l3 filters to generate the RGB image
 *
 *   rgb = l3ApplyFilters(raw, filters, labels, patchSize);
 *
 * HJ, VISTA TEAM, 2015
 */

#include "mex.h"


/* the gateway routine 
   The interface of the function is
   outImg = l3ApplyFilters(rawData, kernels, labels, patchSize);
 */
void mexFunction(int nlhs, mxArray *plhs [],
        int nrhs, const mxArray *prhs[]) {
    
    // Check number of inputs
    if (nrhs != 4) mexErrMsgTxt("Invalid number of inputs");
    // Get camera raw data and size
    mwSize nrows = mxGetM(prhs[0]);
    mwSize ncols = mxGetN(prhs[0]);
    
    if (!mxIsDouble(prhs[0])) mexErrMsgTxt("raw should be double matrix");
    double *raw = mxGetPr(prhs[0]);
    
    // Get labels
    if (!mxIsDouble(prhs[2])) mexErrMsgTxt("labels should be double");
    double *labels = mxGetPr(prhs[2]);
    
    // Get patch size
    double *patchSz = mxGetPr(prhs[3]);
    int patchN = (int)(patchSz[0] * patchSz[1]);
    
    // Determine number of output channels
    int nOut = 0; // number of output channels
    if (!mxIsCell(prhs[1]))
        mexErrMsgTxt("Filter should be in cell array");
    for (mwIndex l=0; l<mxGetM(prhs[1]); l++) {
        mxArray *f = mxGetCell(prhs[1], l);
        if (f != NULL){
            if (mxGetNumberOfDimensions(f) == 1)
                nOut = 1;
            else
                nOut = mxGetN(f);
            break;
        }
    }
    if (nOut == 0)
        mexErrMsgTxt("All kernels are empty.");
    
    // Allocate memory space for output rgb
    mwSize pm[3] = {nrows-(int)patchSz[0]+1,ncols-(int)patchSz[1]+1,nOut};
    if (pm[0] != mxGetM(prhs[2]) || pm[1] != mxGetN(prhs[2]))
        mexErrMsgTxt("size mismatch between raw, labels and patchSz");
    plhs[0] = mxCreateNumericArray(3, pm, mxDOUBLE_CLASS, mxREAL);
    double *out = mxGetPr(plhs[0]);
    
    // Loop through all pixels and compute for output
    for (int r=0; r<pm[0]; r++) {
        for (int c=0; c<pm[1]; c++) {
            // get label for current pixel
            mwIndex l = labels[r + pm[0]*c]-1;  // label for current pixel
            
            // get filter according to label
            mxArray* f = mxGetCell(prhs[1], l);
            if (f == NULL) { 
                // no filter for this class, set output to 0
                for (int channel = 0; channel<nOut; channel++)
                    out[r+pm[0]*c+pm[0]*pm[1]*channel] = 0;
                continue;
            }
            
            if (!mxIsDouble(f))
                mexErrMsgTxt("Filter should be matrix of class DOUBLE");
            double* filter = mxGetPr(f);
            for (int channel=0; channel<nOut; channel++) {
                double* pData = raw + r + c * nrows;
                double val = *(filter++);
                for (int j=0; j < patchSz[1]; j++) {
                    for (int i=0; i < patchSz[0]; i++)
                        val += *pData++ * *filter++;
                    pData += (int)(nrows - patchSz[0]);
                }
                out[r+pm[0]*c+pm[0]*pm[1]*channel] = val;
            }
        }
    }
}