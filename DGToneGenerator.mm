//
//  DGToneGenerator.m
//  DGToneGenerator
//
//  Created by Daniel Cohen Gindi on 5/4/12.
//  Copyright (c) 2011 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/DGToneGenerator
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//`

#import "DGToneGenerator.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface DGToneGenerator ()
{
    //AudioComponentInstance : 오디오 객체 / 오디오 코덱
    AudioComponentInstance toneAudioUnit;
    BOOL isPlaying;
    double sineMultiplierPerSample, sineMultiplierPerSample_2nd;
    double samplesPerSine, samplesPerSine_2nd;
    double samplePosInSine, samplePosInSine_2nd;
    BOOL hasSecondSine;
}
@end

@implementation DGToneGenerator

@synthesize delegate;
@synthesize dB;
void DGToneGenerator_InterruptionListener(void *inClientData, UInt32 inInterruptionState);

OSStatus DGToneGenerator_RenderTone(
                                    /*
                                     AudioUnitRenderActionFlags : 오디오 장치 렌더링을 구성하기위한 플래그.
                                     AudioTimeStamp : 타임스탬프의 여러 표현을 보유하고있다.
                                     AudiobufferList :  오디오 버퍼 구조의 가변 길이 배열을 보유하고있다.
                                     */
                                    void *inRefCon,
                                    AudioUnitRenderActionFlags 	*ioActionFlags,
                                    const AudioTimeStamp          *inTimeStamp,
                                    UInt32 						inBusNumber,
                                    UInt32 						inNumberFrames,
                                    AudioBufferList               *ioData);

- (id)init
{
    if ((self = [super init]))
    {
        /*
         double sampleRate;
         double frequency;
         double secondFrequency;
         double amplitude;
         BOOL manageAudioSession;
         */
        //        _sampleRate = 44100;
        _sampleRate = 22050;
        _frequency = 440;
        _secondFrequency = -1;
        _amplitude = 0.5f;
        _manageAudioSession = YES;
        // kjs add
//        _decibel = 0;
        //        _decibel = -1.0;
//        _dB = (1.0f / 13.0f) / 100000.0f;
        dB = -110;
        //        _dB = (1.0f / 13.0f);
        // add end
        //        printf("init start\n");
        [self updateSine];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    
    if (toneAudioUnit)
    {
        AudioUnitUninitialize(toneAudioUnit);
    }
}

- (void)setAmplitude:(double)amplitude
{
    if (amplitude < 0.0) amplitude = 0.0;
    else if (amplitude > 1.0) amplitude = 1.0f;
    _amplitude = amplitude;
}

#pragma mark - DGToneGenerator Methods

- (void)preInit
{
    if (toneAudioUnit) return;
    //    printf("preInit\n");
    [self setupAudioUnit];
}

- (void)setupAudioUnit
{
    if (toneAudioUnit)
    {//        AudioUnitUninitialize 초기화해제 / 자원(아마도 메모리?)할당 해제
        AudioUnitUninitialize(toneAudioUnit);
    }
    
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    
    //    AudioComponentDescription : 오디오 구성 요소에 대한 정보를 확인
    AudioComponentDescription defaultOutputDescription;
    //    componentType : 구성 요소에 대한 인터페이스를 식별하는 고유 한 4 바이트 코드.
    //    kAudioUnitType_Output : 출력 부는 동시에 입력, 출력, 또는 입력 및 출력 양자 모두를 제공한다. 이는 오디오 프로세싱 유닛 그래프 헤드로서 사용될 수있다.
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    //    componentSubType : 구성 요소의 목적을 표시하기 위해 사용할 수있는 4 바이트 코드
    /*kAudioUnitSubType_RemoteIO
     아이폰 OS 기기의 오디오 입력 및 출력 인터페이스하는 오디오 장치.
     버스 0은 하드웨어에 출력을 제공하며, 버스 1은 하드웨어의 입력을 받아들입니다.I / O 오디오 장치 또는 때때로 리모트 I / O 오디오 장치 호출합니다.*/
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    //    componentManufacturer : 오디오 구성 요소에 대해, 애플에 등록 된 유일한 공급 업체 식별자.
    //    kAudioUnitManufacturer_Apple : 애플 오디오 장치 제조업체 코드.
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    //    componentFlags : 이 값을 0으로 설정합니다.(그냥 0으로 설정하면 되는 듯?)
    defaultOutputDescription.componentFlags = 0;
    //    componentFlagsMask : 이 값을 0으로 설정합니다.(그냥 0으로 설정하면 되는 듯?)
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Get the default playback output unit
    //    AudioComponent : 오디오 컴포넌트
    /*지정된 오디오 구성 요소 후 지정된 AudioComponentDescription 구조와 일치하는 다음 구성 요소를 찾습니다.*/
    //    inAComponent : (여기서는 NULL을 넘김)당신이  검색후  시작하려는 오디오 구성 요소.
    //    inDesc : (여기서는 defaultOutputDescription)내가 찾고 싶은 오디오 구성 요소의 설명 .
    //    return : audio component.
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // Create a new unit based on this that we'll use for output
    //    AudioComponentInstanceNew :  오디오 구성 요소의 새로운 인스턴스를 생성합니다.
    //    defaultOutput : 새로운 인스턴스를 생성 할 오디오 구성 요소입니다.
    //    toneAudioUnit : 출력, 새로운 오디오 구성 요소 인스턴스.
    OSErr err = AudioComponentInstanceNew(defaultOutput, &toneAudioUnit);
    NSAssert1(toneAudioUnit, @"Error creating unit: %hd", err);
    
    // Set our tone rendering function on the unit
    //    AURenderCallbackStruct : 오디오 장치와 입력 콜백 함수를 등록하는 데 사용됩니다.
    AURenderCallbackStruct input;
    input.inputProc = DGToneGenerator_RenderTone;
    input.inputProcRefCon = (__bridge void*)self;
    //    AudioUnitSetProperty : 오디오 장치 속성 값을 설정합니다.
    /*
     inUnit->toneAudioUnit :  속성값을 설정하기 위한 오디오 유닛
     inID->kAudioUnitProperty_SetRenderCallback :  오디오 장치 속성 식별자.
     inScope->kAudioUnitScope_Input : 오디오 유닉 속성에 대한 범위
     inElement -> 0 오디오 유닛 속성의 단위 요소입니다.
     inData->input : 당신이 속성에 적용 할 값입니다. NULL이 될 수 있습니다.
     항상 참조 속성 값을 전달합니다. 예를 들어, 유형 CFStringRef의 속성 값에 대해, 같은 및 myCFString을 전달합니다.
     inDataSize->sizeof(intput) : inData의 매개 변수에 제공하는 데이터의 크기입니다.
     */
    err = AudioUnitSetProperty(toneAudioUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
    // Set the format to 32 bit, single channel, floating point, linear PCM
    //    AudioStreamBasicDescription : 오디오 스트림에 대한 오디오 데이터 형식 사양.
    AudioStreamBasicDescription streamFormat;
    /*mSampleRate : 스트림이 정상 속도로 재생되는 스트림에있는 데이터의 초당 프레임 수입니다. 압축 된 포맷의 경우,이 필드는 데이터 압축을 등가의 초당 프레임의 수를 나타낸다.
     mSampleRate 필드는이 구조가 지원하는 형식의 목록에 사용되는 경우를 제외하고 0이 아닌 수 있어야합니다*/
    streamFormat.mSampleRate = _sampleRate;
    /*mFormatID : 스트림의 일반 오디오 데이터 포맷을 지정하는 식별자. "Audio Data Format Identifiers"를 참조하십시오. 이 값은 0이 아닌 수 있어야합니다.
     kAudioFormatLinearPCM : 리니어 PCM을 지정하는 키, 패킷 당 하나의 프레임 비 압축 오디오 데이터 형식입니다. "AudioStreamBasicDescription 플래그"의 리니어 PCM 형식 플래그를 사용합니다.*/
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    
    /*mFormatFlags : 형식 별 플래그 형식의 세부 사항을 지정합니다. 어떤 형식 플래그를 표시하지 않으려면 0으로 설정합니다. 각 형식에 적용되는 플래그 "Audio Data Format Identifiers"를 참조하십시오.
     kAudioFormatFlagsNativeFloatPacked :네이티브 엔디안 부동 소수점 데이터의 표준 형식에 대한 플래그에 대해서 완벽하게 포장,
     kAudioFormatFlagIsNonInterleaved :각 채널에 대한 샘플이 인접 위치하며 채널을 끝으로 끝을 배치되어, 분명 각각의 프레임에 대한 샘플이 연속적으로 배치하는 경우와 프레임 끝과 끝을 배치하는 경우 설정합니다. 이 플래그와 AudioStreamBasicDescription AudioBufferList 구조의 사용에 영향을 미친다; 자세한 내용은 AudioStreamBasicDescription 구조의 설명을 참조하십시오.*/
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    /*mBytesPerPacket : 오디오 데이터 패킷의 바이트 수. 가변 패킷 크기를 나타 내기 원하면 이 필드를 0으로 설정합니다.
     가변 패킷 크기를 사용하여 포맷 들어 AudioStreamPacketDescription 구조를 사용하여 각 패킷의 크기를 지정.*/
    streamFormat.mBytesPerPacket = 4; // four bytes per packet
    /*mFramesPerPacket : 오디오 데이터 패킷의 프레임 번호. 압축 오디오의 경우, 값이 가변 비트 레이트 포맷 1이고, 값이 큰 고정 된 수, 예컨대 AAC를위한 1024이다. 이러한 오그 보비스와 같은 패킷 당 프레임의 변수 번호 형식의 경우,이 필드를 0으로 설정합니다.*/
    streamFormat.mFramesPerPacket = 1;
    /*
     mBytesPerFrame : 음성 버퍼 내의 다음 프레임의 시작에 하나의 프레임의 시작으로부터의 바이트 수.
     압축 포맷이 필드를 0으로 설정합니다.
     */
    streamFormat.mBytesPerFrame = 4; // four bytes per frame
    //    mChannelsPerFrame : 오디오 데이터의 각 프레임의 채널 번호. 이 값은 0이 아닌 수 있어야합니다.
    streamFormat.mChannelsPerFrame = 2;
    /*
     mBitsPerChannel : 하나의 오디오 샘플의 비트 수.
     압축 포맷이 필드를 0으로 설정합니다.
     */
    streamFormat.mBitsPerChannel = 4 * 8; // four bytes (* 8 bits) per channel
    /*
     AudioUnitSetProperty : 오디오 장치 속성 값을 설정합니다.
     inUnit->toneAudioUnit :  속성값을 설정하기 위한 오디오 유닛
     inID->kAudioUnitProperty_StreamFormat :  오디오 장치 속성 식별자.
     inScope->kAudioUnitScope_Input : 오디오 유닉 속성에 대한 범위
     inElement -> 0 오디오 유닛 속성의 단위 요소입니다.
     inData->streamFormat : 당신이 속성에 적용 할 값입니다. NULL이 될 수 있습니다.
     항상 참조 속성 값을 전달합니다. 예를 들어, 유형 CFStringRef의 속성 값에 대해, 같은 및 myCFString을 전달합니다.
     inDataSize->AudioStreamBasicDescription: inData의 매개 변수에 제공하는 데이터의 크기입니다.
     */
    err = AudioUnitSetProperty (toneAudioUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
    
    // Stop changing parameters on the unit
    // AudioUnitInitialize : 오디오유닛에 메모리할당/초기화
    err = AudioUnitInitialize(toneAudioUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
}

- (void)play
{//BOOL manageAudioSession;
    if (_manageAudioSession)
    {
        //        BOOL preventMute;
        //sharedInstance   싱글 오디오 세션을 돌려줍니다.(싱글턴)
        //setActive: error: >> 앱의 오디오 세션을 활성화/비활성화합니다. err: 는 오류에 관한 설명을 NSError로 전달, 원하지 않으면 nil로 설정
        //        AVAudioSessionCategoryPlayback : 백그라운드상에서도 즉, 사운드락이나 잠금모드일때도 오디오 플레이 가능하게 함
        //        AVAudioSessionCategorySoloAmbient : 동시재생이 안되게함
        //    setCategory: error: >> 현재 오디오 세션 카테고리를 설정.
        [AVAudioSession.sharedInstance setActive:YES error:nil];
        NSString *sessionCategory = _preventMute ? AVAudioSessionCategoryPlayback : AVAudioSessionCategorySoloAmbient;
        [AVAudioSession.sharedInstance setCategory:sessionCategory error:nil];
    }
    
    if (toneAudioUnit)
    {
        [self stop];
    }
    
    [self preInit];
    
    // Start playback
    //    AudioOutputUnitStart : 오디오 유닛을 시작
    OSErr err = AudioOutputUnitStart(toneAudioUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    
    isPlaying = YES;
}

- (void)stop
{
    //BOOL manageAudioSession;
    //sharedInstance   싱글 오디오 세션을 돌려줍니다.
    //setActive: error: >> 앱의 오디오 세션을 활성화/비활성화합니다. err: 는 오류에 관한 설명을 NSError로 전달, 원하지 않으면 nil로 설정
    
    //    if (_manageAudioSession)
    //    {
    //        [AVAudioSession.sharedInstance setActive:NO error:nil];
    //    }
    if (toneAudioUnit)
    {
        //AudioOutputUnitStop 오디오 유닛 중지
        //        AudioUnitUninitialize 초기화해제 / 자원(아마도 메모리?)할당 해제
        //        AudioComponentInstanceDispose 인스턴스 파괴
        AudioOutputUnitStop(toneAudioUnit);
        AudioUnitUninitialize(toneAudioUnit);
        AudioComponentInstanceDispose(toneAudioUnit);
        toneAudioUnit = nil;
    }
    if (_manageAudioSession)
    {
        [AVAudioSession.sharedInstance setActive:NO error:nil];
    }
    
    isPlaying = NO;
}

- (BOOL)isPlaying
{
    return isPlaying;
}

- (void)setDtmfFrequency:(DGToneGeneratorDtmf)dtmf
{
    switch (dtmf)
    {
        default:
        case DGToneGeneratorDtmf0: // 125 Hz
            //            self.frequency = 941;
            //            self.secondFrequency = 1336;
            self.frequency = 62.5;
            self.secondFrequency = 187.5;
            break;
        case DGToneGeneratorDtmf1: //250 Hz
            //            self.frequency = 697;
            //            self.secondFrequency = 1209;
            self.frequency = 187.5;
            self.secondFrequency = 312.5;
            break;
        case DGToneGeneratorDtmf2: //500 Hz
            //            self.frequency = 697;
            //            self.secondFrequency = 1336;
            self.frequency = 437.5;
            self.secondFrequency = 562.5;
            break;
        case DGToneGeneratorDtmf3: //1000 Hz
            //            self.frequency = 697;
            //            self.secondFrequency = 1477;
            self.frequency = 937.5;
            self.secondFrequency = 1062.5;
            break;
        case DGToneGeneratorDtmf4: //2000 Hz
            //            self.frequency = 770;
            //            self.secondFrequency = 1209;
            self.frequency = 1937.5;
            self.secondFrequency = 2062.5;
            break;
        case DGToneGeneratorDtmf5: // 4000 Hz
            //            self.frequency = 770;
            //            self.secondFrequency = 1336;
            self.frequency = 3937.5;
            self.secondFrequency = 4062.5;
            break;
        case DGToneGeneratorDtmf6: // 8000 Hz
            //            self.frequency = 770;
            //            self.secondFrequency = 1477;
            self.frequency = 7937.5;
            self.secondFrequency = 8062.5;
            break;
            //        case DGToneGeneratorDtmf7:
            //            self.frequency = 6937.5;
            //            self.secondFrequency = 7062.5;
            //            break;
            //        case DGToneGeneratorDtmf8:
            //            self.frequency = 7937.5;
            //            self.secondFrequency = 8062.5;
            //            break;
            //        case DGToneGeneratorDtmf9:
            //            self.frequency = 852;
            //            self.secondFrequency = 1477;
            //            break;
            //        case DGToneGeneratorDtmfStar:
            //            self.frequency = 941;
            //            self.secondFrequency = 1209;
            //            break;
            //        case DGToneGeneratorDtmfPound:
            //            self.frequency = 941;
            //            self.secondFrequency = 1477;
            //            break;
            //        case DGToneGeneratorDtmfA:
            //            self.frequency = 697;
            //            self.secondFrequency = 1633;
            //            break;
            //        case DGToneGeneratorDtmfB:
            //            self.frequency = 770;
            //            self.secondFrequency = 1633;
            //            break;
            //        case DGToneGeneratorDtmfC:
            //            self.frequency = 852;
            //            self.secondFrequency = 1633;
            //            break;
            //        case DGToneGeneratorDtmfD:
            //            self.frequency = 941;
            //            self.secondFrequency = 1633;
            //            break;
    }
    [self updateSine];
}

- (void)setFrequency:(double)frequency
{
    _frequency = frequency;
    [self updateSine];
}

- (void)setSecondFrequency:(double)secondFrequency
{
    _secondFrequency = secondFrequency;
    [self updateSine];
}

- (void)setSampleRate:(double)sampleRate
{
    _sampleRate = sampleRate;
    BOOL wasPlaying = self.isPlaying;
    [self stop];
    [self updateSine];
    if (toneAudioUnit)
    { // If we were already initialized... Make sure we still are
        [self setupAudioUnit];
    }
    if (wasPlaying)
    { // If we were playing, resume playing
        [self play];
    }
}

- (void)setPreventMute:(BOOL)preventMute
{
    _preventMute = preventMute;
    if (_manageAudioSession)
    {
        //        AVAudioSessionCategoryPlayback : 백그라운드상에서도 즉, 사운드락이나 잠금모드일때도 오디오 플레이 가능하게 함
        //        AVAudioSessionCategorySoloAmbient : 동시재생이 안되게함
        NSString *sessionCategory = _preventMute ? AVAudioSessionCategoryPlayback : AVAudioSessionCategorySoloAmbient;
        [AVAudioSession.sharedInstance setCategory:sessionCategory error:nil];
    }
}

- (void)updateSine // 아마 주파수를 맞춰주는 곳??
{
    //    #define M_PI        3.14159265358979323846264338327950288   /* pi             */
    //    BOOL hasSecondSine;
    //    double frequency;
    //    BOOL hasSecondSine;
    //    double secondFrequency;
    //    double samplesPerSine, samplesPerSine_2nd;
    //    double sampleRate;
    //    double sineMultiplierPerSample, sineMultiplierPerSample_2nd;
    //    double samplePosInSine, samplePosInSine_2nd;
    
    const double M_2PI = 2.0 * M_PI; //  PI값의 2배
    hasSecondSine = NO;
    if (self->_frequency > 0.0 && self->_secondFrequency <= 0.0) // frequency가 0보다 크고 secondFrequency가 0이하일때.
    {
        samplesPerSine = self->_sampleRate / self->_frequency;
        sineMultiplierPerSample = M_2PI / samplesPerSine;
        while (samplePosInSine >= samplesPerSine) samplePosInSine -= samplesPerSine; // samplePosInSine이 samplePerSine보다 큰값일 동안 samplePerSine만큼 빼줌.
        //        printf("frequency 0 up, secondfrequency 0 down\n");
    }
    else if (self->_secondFrequency > 0.0 && self->_frequency <= 0.0) // secondFrequency가 0보다 크고 frequncy가 0이하일떄
    {
        samplesPerSine_2nd = self->_sampleRate / self->_secondFrequency;
        sineMultiplierPerSample_2nd = M_2PI / samplesPerSine_2nd;
        while (samplePosInSine_2nd >= samplesPerSine_2nd) samplePosInSine_2nd -= samplesPerSine_2nd;
        //        printf("frequency 0 down, secondfrequency 0 up\n");
    }
    else if (self->_secondFrequency > 0.0 && self->_frequency > 0.0) // secondFrequency, frequency 둘다 0보다 클 때.
    {
        hasSecondSine = YES;
        samplesPerSine = self->_sampleRate / self->_frequency;
        sineMultiplierPerSample = M_2PI / samplesPerSine;
        samplesPerSine_2nd = self->_sampleRate / self->_secondFrequency;
        sineMultiplierPerSample_2nd = M_2PI / samplesPerSine_2nd;
        while (samplePosInSine >= samplesPerSine) samplePosInSine -= samplesPerSine;
        while (samplePosInSine_2nd >= samplesPerSine_2nd) samplePosInSine_2nd -= samplesPerSine_2nd;
        //        printf("all up\n");
    }
}

#pragma mark - AudioToolbox C helpers

void DGToneGenerator_InterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    DGToneGenerator *self = (__bridge DGToneGenerator*)inClientData;
    //    printf("DGToneGenerator_InterruptionListener\n");
    [self stop];
}
OSStatus DGToneGenerator_RenderTone(
                                    void *inRefCon,
                                    AudioUnitRenderActionFlags 	*ioActionFlags,
                                    const AudioTimeStamp 		*inTimeStamp,
                                    UInt32 						inBusNumber,
                                    UInt32 						inNumberFrames,
                                    AudioBufferList 			*ioData)

{
    DGToneGenerator *self = (__bridge DGToneGenerator *)inRefCon;
    float dBTemp = 0.0;
    double samplePosInSine = self->samplePosInSine;
    double samplePosInSine_2nd = self->samplePosInSine_2nd;
    double samplesPerSine = self->samplesPerSine;
    double samplesPerSine_2nd = self->samplesPerSine_2nd;
    double sineMultiplierPerSample = self->sineMultiplierPerSample;
    double sineMultiplierPerSample_2nd = self->sineMultiplierPerSample_2nd;
//    double amplitude = self->_decibel; // kjs add
    double amplitude = powf(10, (0.05 * self->dB));
    BOOL hasSecondSine = self->hasSecondSine;
    //    printf("amplitude:%f \n",amplitude);
    // This is a mono tone generator so we only need the first buffer
    Float32 *buffer = (Float32 *)ioData->mBuffers[0].mData;// left
    Float32 *buffer2 = (Float32*)ioData->mBuffers[1].mData; // right
    //    printf("numberBuffers : %d\n",(unsigned int)ioData->mNumberBuffers);
    // Generate the samples
    Float32 sample;
    //    printf("before amplitude : %f\n",amplitude);
    for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        if (hasSecondSine)
        {
            sample = (sin(sineMultiplierPerSample * samplePosInSine) +
                      sin(sineMultiplierPerSample_2nd * samplePosInSine_2nd)) * amplitude;
            samplePosInSine_2nd++;
            while (samplePosInSine_2nd >= samplesPerSine_2nd) samplePosInSine_2nd -= samplesPerSine_2nd;
        }
        else
        {
            sample = sin(sineMultiplierPerSample * samplePosInSine) * amplitude;
        }
        
        samplePosInSine++;
        while (samplePosInSine >= samplesPerSine) samplePosInSine -= samplesPerSine;
        
        buffer[frame] = sample;
        buffer2[frame] = sample;

        if(self.muteLeft){
            buffer[frame] = 0; // left mute
        }if(self.muteRight){
            buffer2[frame] = 0;} // right mute
        dBTemp = buffer[frame];
        //            printf("buffer value :%f\n",buffer[frame]);
    }
    self->samplePosInSine = samplePosInSine;
    self->samplePosInSine_2nd = samplePosInSine_2nd;
    if(self->dB <= 10){ // kjs add
//        self->_decibel = self->_decibel + self->_dB;
        self->dB = self->dB + 0.05;
//        printf("after amplitude : %f\n",amplitude);
    } // add end
    
    dBTemp =  20 * log10(amplitude);
    printf("dbTemp : %f\n",dBTemp);
    printf("db : %f\n",self->dB);
    [self.delegate increaseGraph:self->dB];
    //    printf("this is audioplay\n");
    //    float dbTemp2  = powf(10, (0.05 * dbTemp)); dbTemp2엔 amplitude 값이 들어감 *dbTemp 는 dB값
//    printf("dbTemp : %fself db : %f\n",dBTemp,self->dB);
    return noErr;
}

@end
