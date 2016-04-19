//
//  Equalizer10.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 13..
//  Copyright (c) 2015년 Mac. All rights reserved.
//


#include <stdio.h>

#import "Equalizer10.h"


void initializeEqualizer10Band(Equalizer10Band *EQDef, Float32 sampleRate, Float32 initialVolume) {
    
    //different band values
    //    initBandPassFilter(&EQDef->BPFilter1, sampleRate, 16, 32);
    //    initBandPassFilter(&EQDef->BPFilter2, sampleRate, 32, 64);
    //    initBandPassFilter(&EQDef->BPFilter3, sampleRate, 64, 125);
    //    initBandPassFilter(&EQDef->BPFilter4, sampleRate, 125, 250);
    //    initBandPassFilter(&EQDef->BPFilter5, sampleRate, 250, 500);
    //    initBandPassFilter(&EQDef->BPFilter6, sampleRate, 500, 1000);
    //    initBandPassFilter(&EQDef->BPFilter7, sampleRate, 1000, 2000);
    //    initBandPassFilter(&EQDef->BPFilter8, sampleRate, 2000, 4000);
    //    initBandPassFilter(&EQDef->BPFilter9, sampleRate, 4000, 8000);
    //    initBandPassFilter(&EQDef->BPFilter10, sampleRate, 8000, 16000);
    //
    //    initBandPassFilter(&EQDef->BPFilter1, sampleRate, 16, 64);
    //    initBandPassFilter(&EQDef->BPFilter2, sampleRate, 64, 125);
    //    initBandPassFilter(&EQDef->BPFilter3, sampleRate, 125, 250);
    //    initBandPassFilter(&EQDef->BPFilter4, sampleRate, 250, 500);
    //    initBandPassFilter(&EQDef->BPFilter5, sampleRate, 500, 1000);
    //    initBandPassFilter(&EQDef->BPFilter6, sampleRate, 1000, 2000);
    //    initBandPassFilter(&EQDef->BPFilter7, sampleRate, 2000, 4000);
    //    initBandPassFilter(&EQDef->BPFilter8, sampleRate, 4000, 8000);
    //    initBandPassFilter(&EQDef->BPFilter9, sampleRate, 8000, 12000);
    //    initBandPassFilter(&EQDef->BPFilter10, sampleRate, 12000, 16000);
    
    
    
    //    initBandPassFilter(&EQDef->BPFilter1, sampleRate, 16, 125);
    //    initBandPassFilter(&EQDef->BPFilter2, sampleRate, 125, 250);
    //    initBandPassFilter(&EQDef->BPFilter3, sampleRate, 250, 500);
    //    initBandPassFilter(&EQDef->BPFilter4, sampleRate, 500, 1000);
    //    initBandPassFilter(&EQDef->BPFilter5, sampleRate, 1000, 2000);
    //    initBandPassFilter(&EQDef->BPFilter6, sampleRate, 2000, 4000);
    //    initBandPassFilter(&EQDef->BPFilter7, sampleRate, 4000, 6000);
    //    initBandPassFilter(&EQDef->BPFilter8, sampleRate, 6000, 8000);
    //    initBandPassFilter(&EQDef->BPFilter9, sampleRate, 8000, 12000);
    //    initBandPassFilter(&EQDef->BPFilter10, sampleRate, 12000, 16000);
    
    
    /*
     initBandPassFilter(&EQDef->BPFilter1, sampleRate, 16, 250);
     initBandPassFilter(&EQDef->BPFilter2, sampleRate, 250, 500);
     initBandPassFilter(&EQDef->BPFilter3, sampleRate, 500, 1000);
     initBandPassFilter(&EQDef->BPFilter4, sampleRate, 1000, 2000);
     initBandPassFilter(&EQDef->BPFilter5, sampleRate, 2000, 4000);
     initBandPassFilter(&EQDef->BPFilter6, sampleRate, 4000, 6000);
     initBandPassFilter(&EQDef->BPFilter7, sampleRate, 6000, 8000);
     initBandPassFilter(&EQDef->BPFilter8, sampleRate, 8000, 10000);
     initBandPassFilter(&EQDef->BPFilter9, sampleRate, 10000, 12000);
     initBandPassFilter(&EQDef->BPFilter10, sampleRate, 12000, 16000); */
    
    initBandPassFilter(&EQDef->BPFilter1, sampleRate, 62.5, 187.5);  //중심주파수 125
    initBandPassFilter(&EQDef->BPFilter2, sampleRate, 187.5, 312.5); //250
    initBandPassFilter(&EQDef->BPFilter3, sampleRate, 437.5, 562.5); //500
    initBandPassFilter(&EQDef->BPFilter4, sampleRate, 937.5, 1062.5); //1000
    initBandPassFilter(&EQDef->BPFilter5, sampleRate, 1937.5, 2062.5); //2000
    initBandPassFilter(&EQDef->BPFilter6, sampleRate, 3937.5, 4062.5); //4000
    initBandPassFilter(&EQDef->BPFilter7, sampleRate, 5937.5, 6062.5); //6000
    initBandPassFilter(&EQDef->BPFilter8, sampleRate, 6937.5, 7062.5); //7000
    initBandPassFilter(&EQDef->BPFilter9, sampleRate, 7937.5, 8062.5); //8000
    initBandPassFilter(&EQDef->BPFilter10, sampleRate, 8937.5, 9062.5); //9000
    
    //  initBandPassFilter(&EQDef->BPFilter11), sampleRate, 9065, 10000.5);//10000
    //Channel 128 by Yongil Choi 2015. 1. 9 금요일
    
    
    
    EQDef->band1Volume = EQDef->band2Volume = EQDef->band3Volume = EQDef->band4Volume = EQDef->band5Volume =
    EQDef->band6Volume = EQDef->band7Volume = EQDef->band8Volume = EQDef->band9Volume = EQDef->band10Volume = initialVolume;
}

void loadDataAddEqualizer10Band(Equalizer10Band *EQDef, float valueArray[]){
    EQDef->band1Volume = valueArray[0];
    EQDef->band2Volume = valueArray[1];
    EQDef->band3Volume = valueArray[2];
    EQDef->band4Volume = valueArray[3];
    EQDef->band5Volume = valueArray[4];
    EQDef->band6Volume = valueArray[5];
    EQDef->band7Volume = valueArray[6];
    EQDef->band8Volume = valueArray[7];
    EQDef->band9Volume = valueArray[8];
    EQDef->band10Volume = valueArray[9];
    for(int i = 0; i<10;i++){
        printf("valueArray : %f\n",valueArray[i]);
    }
    
}

Float32 equalizer10BandTick(Equalizer10Band *EQDef, Float32 inputSample) {
//    printf("equalizer10BandTick work\n");
    return bandPassFilterTick(&EQDef->BPFilter1, inputSample)*EQDef->band1Volume +
    bandPassFilterTick(&EQDef->BPFilter2, inputSample)*EQDef->band2Volume +
    bandPassFilterTick(&EQDef->BPFilter3, inputSample)*EQDef->band3Volume +
    bandPassFilterTick(&EQDef->BPFilter4, inputSample)*EQDef->band4Volume +
    bandPassFilterTick(&EQDef->BPFilter5, inputSample)*EQDef->band5Volume +
    bandPassFilterTick(&EQDef->BPFilter6, inputSample)*EQDef->band6Volume +
    bandPassFilterTick(&EQDef->BPFilter7, inputSample)*EQDef->band7Volume +
    bandPassFilterTick(&EQDef->BPFilter8, inputSample)*EQDef->band8Volume +
    bandPassFilterTick(&EQDef->BPFilter9, inputSample)*EQDef->band9Volume +
    bandPassFilterTick(&EQDef->BPFilter10, inputSample)*EQDef->band10Volume;
}