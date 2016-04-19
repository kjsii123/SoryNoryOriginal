//
//  Equalizer10.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 13..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#ifndef HearingAids_Equalizer10_h
#define HearingAids_Equalizer10_h



#endif


#import "MyCFilter.h"




typedef struct Equalizer10Band {
    
    Float32 band1Volume;
    Float32 band2Volume;
    Float32 band3Volume;
    Float32 band4Volume;
    Float32 band5Volume;
    Float32 band6Volume;
    Float32 band7Volume;
    Float32 band8Volume;
    Float32 band9Volume;
    Float32 band10Volume;
    
    MyCBandPass BPFilter1;
    MyCBandPass BPFilter2;
    MyCBandPass BPFilter3;
    MyCBandPass BPFilter4;
    MyCBandPass BPFilter5;
    MyCBandPass BPFilter6;
    MyCBandPass BPFilter7;
    MyCBandPass BPFilter8;
    MyCBandPass BPFilter9;
    MyCBandPass BPFilter10;
    
} Equalizer10Band;




/// Initialize it before use. Initialize the variable of type Equalizer10Band struct.
void initializeEqualizer10Band(Equalizer10Band *EQDef, Float32 sampleRate, Float32 initialVolume);
void loadDataAddEqualizer10Band(Equalizer10Band *EQdef, float arrayValue[]);

/// provide input sample and initialized equalizer - get back output sample.
Float32 equalizer10BandTick(Equalizer10Band *EQDef, Float32 inputSample);



