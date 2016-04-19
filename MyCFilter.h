//
//  MyCFilter.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 13..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#ifndef HearingAids_MyCFilter_h
#define HearingAids_MyCFilter_h


#include <MacTypes.h>


typedef struct MyCLowPass {
    
    volatile Float32 lowPassFilterConstant;
    volatile Float32 lowPassFilterValue;
    
} MyCLowPass;


typedef struct MyCHighPass {
    volatile Float32 highPassFilterConstant;
    volatile Float32 highPassFilterValue;
    volatile Float32 highPassFilterLastNewVal;
} MyCHighPass;





typedef struct MyCBandPass {
    MyCLowPass      lowpassF;
    MyCHighPass     highpassF;
} MyCBandPass;











typedef struct MyCEqualizer {
    Float32 maxFreq;
    Float32 minFreq;
    
    int numberOfBands;
} MyCEqualizer;






volatile void initBandPassFilter(MyCBandPass *filterDef, Float32 sampleRate, Float32 lowestFreq, Float32 highestFreq);

Float32 bandPassFilterTick(MyCBandPass *filterDef, Float32 newVal);




volatile void setLowPassRateAndCuttof(MyCLowPass *filterDef, Float32 rateVal, Float32 cuttofFreq);
Float32 lowPassFilterTick(MyCLowPass *filterDef, Float32 newVal);


volatile void setHigPassRateAndCuttof(MyCHighPass *filterDef, Float32 rateVal, Float32 cuttofFreq);
volatile Float32 highPassFilterTick(MyCHighPass *filterDef, Float32 newVal);


#endif
