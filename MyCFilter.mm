//
//  MyCFilter.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 13..
//  Copyright (c) 2015년 Mac. All rights reserved.
//



#include <stdio.h>
#include "MyCFilter.h"


volatile void setLowPassRateAndCuttof(MyCLowPass *filterDef, Float32 rateVal, Float32 cuttofFreq) {
    if (rateVal!=0 && cuttofFreq!=0) {
        Float32 dt = 1.0 / rateVal;
        Float32 RC = 1.0 / cuttofFreq;
        filterDef->lowPassFilterConstant = dt / (dt + RC);
    }
}


Float32 lowPassFilterTick(MyCLowPass *filterDef, Float32 newVal) {
    filterDef->lowPassFilterValue = newVal * filterDef->lowPassFilterConstant + filterDef->lowPassFilterValue * (1.0 - filterDef->lowPassFilterConstant);
    return filterDef->lowPassFilterValue;
}







volatile void setHigPassRateAndCuttof(MyCHighPass *filterDef, Float32 rateVal, Float32 cuttofFreq) {
    if (rateVal!=0 && cuttofFreq!=0) {
        Float32 dt = 1.0 / rateVal;
        Float32 RC = 1.0 / cuttofFreq;
        filterDef->highPassFilterConstant = RC / (dt + RC);
    }
}

volatile Float32 highPassFilterTick(MyCHighPass *filterDef, Float32 newVal) {
    filterDef->highPassFilterValue = filterDef->highPassFilterConstant * (filterDef->highPassFilterValue + newVal - filterDef->highPassFilterLastNewVal);
    filterDef->highPassFilterLastNewVal = newVal;
    return  filterDef->highPassFilterValue;
}




volatile void initBandPassFilter(MyCBandPass *filterDef, Float32 sampleRate, Float32 lowestFreq, Float32 highestFreq) {
    setHigPassRateAndCuttof(&(filterDef->highpassF), sampleRate, lowestFreq);
    setLowPassRateAndCuttof(&(filterDef->lowpassF), sampleRate, highestFreq);
    printf("=============================================================================================\n");
    printf("sample rate :  %f    lowestFreq : %f    highestFreq : %f\n",sampleRate,lowestFreq,highestFreq);
    printf("highPassFilterConstant : %f\n",filterDef->highpassF.highPassFilterConstant);
    printf("lowPassFilterConstant : %f\n",filterDef->lowpassF.lowPassFilterConstant);
    
}

Float32 bandPassFilterTick(MyCBandPass *filterDef, Float32 newVal) {
    Float32 filteredValue;
    filteredValue = lowPassFilterTick(&(filterDef->lowpassF), newVal);
    filteredValue = highPassFilterTick(&(filterDef->highpassF), filteredValue);
    return filteredValue;
}






