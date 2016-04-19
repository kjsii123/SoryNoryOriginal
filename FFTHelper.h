//
//  FFTHelperRef.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 2..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#ifndef SoryNoryFinal_FFTHelperRef_h
#define SoryNoryFinal_FFTHelperRef_h



#import <Accelerate/Accelerate.h>
#include <MacTypes.h>


typedef struct FFTHelperRef {
    FFTSetup fftSetup;
    COMPLEX_SPLIT complexA;
    Float32 *outFFTData;
    
    Float32 *invertedCheckData;
    
    //    Float32 *optional_FFTRealPart;
    //    Float32 *optional_FFTImgPart;
} FFTHelperRef;




//void initFFTHelperRef(

FFTHelperRef * FFTHelperCreate(long numberOfSamples);


Float32 * computeFFT(FFTHelperRef *fftHelperRef, Float32 *timeDomainData, long numSamples);


void FFTHelperRelease(FFTHelperRef *fftHelper);


#endif
