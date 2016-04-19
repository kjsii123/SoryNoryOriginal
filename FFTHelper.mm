//
//  FFTHelper.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 2..
//  Copyright (c) 2015년 Mac. All rights reserved.
//


#include <stdio.h>


#import "FFTHelper.h"


FFTHelperRef * FFTHelperCreate(long numberOfSamples) {
    
    
    //    vDSP_Length log2n = log2f(numSamples);
    //	fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    //	int nOver2 = numSamples/2;
    //	A.realp = (float *) malloc(nOver2*sizeof(float));
    //	A.imagp = (float *) malloc(nOver2*sizeof(float));
    
    
    FFTHelperRef *helperRef = (FFTHelperRef*) malloc(sizeof(FFTHelperRef));
    vDSP_Length log2n = log2f(numberOfSamples);
    helperRef->fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    int nOver2 = (int) numberOfSamples/2;
    helperRef->complexA.realp = (Float32*) malloc(nOver2*sizeof(Float32) );
    helperRef->complexA.imagp = (Float32*) malloc(nOver2*sizeof(Float32) );
    
    helperRef->outFFTData = (Float32 *) malloc(nOver2*sizeof(Float32) );
    memset(helperRef->outFFTData, 0, nOver2*sizeof(Float32) );
    
    helperRef->invertedCheckData = (Float32*) malloc(numberOfSamples*sizeof(Float32) );
    
    return  helperRef;
}


Float32 * computeFFT(FFTHelperRef *fftHelperRef, Float32 *timeDomainData, long numSamples) {
    
    //    static Float32 strongestFrequencyHZ(Float32 *buffer, FFTHelperRef *fftHelper, UInt32 frameSize, Float32 *freqValue)
    
    //    int i;
    vDSP_Length log2n = log2f(numSamples);
    Float32 mFFTNormFactor = 1.0/(2*numSamples);
    
    //Convert float array of reals samples to COMPLEX_SPLIT array A
    vDSP_ctoz((COMPLEX*)timeDomainData, 2, &(fftHelperRef->complexA), 1, numSamples/2);
    
    /*  printf(" \n");
     for (int i=0; i<=numSamples/2; i++) {
     printf("\n BEFORE: real=%f img=%f", fftHelperRef->complexA.realp[i], fftHelperRef->complexA.imagp[i]);
     } */
    
    
    //Perform FFT using fftSetup and A
    //Results are returned in A
    vDSP_fft_zrip(fftHelperRef->fftSetup, &(fftHelperRef->complexA), 1, log2n, FFT_FORWARD);
    
    //scale fft
    vDSP_vsmul(fftHelperRef->complexA.realp, 1, &mFFTNormFactor, fftHelperRef->complexA.realp, 1, numSamples/2);
    vDSP_vsmul(fftHelperRef->complexA.imagp, 1, &mFFTNormFactor, fftHelperRef->complexA.imagp, 1, numSamples/2);
    
    
    /*   for (int i=0; i<=numSamples/2; i++) {
     printf("\n AFTER: real=%f img=%f", fftHelperRef->complexA.realp[i], fftHelperRef->complexA.imagp[i]);
     }
     printf(" \n");
     */
    vDSP_zvmags(&(fftHelperRef->complexA), 1, fftHelperRef->outFFTData, 1, numSamples/2);
    
    
    //to check everything =============================
    vDSP_fft_zrip(fftHelperRef->fftSetup, &(fftHelperRef->complexA), 1, log2n, FFT_INVERSE);
    vDSP_ztoc( &(fftHelperRef->complexA), 1, (COMPLEX *) fftHelperRef->invertedCheckData , 2, numSamples/2);
    //=================================================
    /*   for (int i=0; i<=numSamples/2; i++) {
     printf("\n AFTER2: real=%f img=%f", fftHelperRef->complexA.realp[i], fftHelperRef->complexA.imagp[i]);
     }
     printf(" \n");
     
     */
    return fftHelperRef->outFFTData;
}





void FFTHelperRelease(FFTHelperRef *fftHelper) {
    vDSP_destroy_fftsetup(fftHelper->fftSetup);
    free(fftHelper->complexA.realp);
    free(fftHelper->complexA.imagp);
    free(fftHelper->outFFTData);
    free(fftHelper->invertedCheckData);
    free(fftHelper);
    fftHelper = NULL;
}

