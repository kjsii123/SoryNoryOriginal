
#import "HomeViewController.h"
#import "mo_audio.h"
#import "MyCFilter.h"
#import "Equalizer10.h"
#import "SuperpoweredCompressor.h"

/*
 
 viewDidAppear :
 1파일에서 이퀄값 가저 오기.
 1 - 1 NSDictionary에는 NSArray로 넣어놨으니 빼와서 일반 배열 <ex)float eqValue[10];>에 band값 저장 
 1 - 2 이 값은 추후 메소드의 파라미터로 넘기기
 2 initializeEqualizer10Band 메소드와 비슷한 메소드 만들기
 2 - 1 메소드명은 loadDataAddEqualizer10Band(배열명);
 3 파라미터값은 추후 생각.(아마 배열을 그대로 넣어서 쓰면 될듯?)
 4. 바로 적용 되는지 확인.
 etc . 그 밖의 고려사항이 있을까?
 
 
 */


#define HEADPHONES_AND_LOOPBACK_ALERT_KEY       @"HaLAK"

#define BUFFER_TO_DRAW_SIZE  10240
#define LEFT 1
#define RIGHT 0
static Float32 *bufferToDraw1 = NULL;
static int framesToDraw1 =1;

static Float32 *bufferToDraw2 = NULL;
static int framesToDraw2 = 1;




NSDictionary* dataDict;
PointerData* pointerData;
#pragma mark Headphones detection
static HomeViewController *mainController = nil; // ??

OsciGraph *homeOsciView; // temp

volatile static BOOL headphonesConnected;

#pragma mark Is Headphones Connected
BOOL isHeadsetPluggedIn() {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
                                              &routeSize,
                                              &route
                                              );
    NSLog(@"%@", route);
    return (!error && (route != NULL) && ([(NSString*)route rangeOfString:@"Head"].location != NSNotFound));
}

void audioRouteChangeListenerCallback (void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData)
{
    if (mainController!=nil) {
        printf("do?\n");
        headphonesConnected = isHeadsetPluggedIn();
        [mainController headphonesConnected:isHeadsetPluggedIn()];
        
    }
    
    CFStringRef cur_audio_route;
    UInt32 dataSize = sizeof(cur_audio_route);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &dataSize, &cur_audio_route);
    
    if ([(NSString*)cur_audio_route isEqualToString:@"ReceiverAndMicrophone"]) {
        printf("in ReceiverAndMicrophone\n");
        CFStringRef audio_route = (CFStringRef)'spkr';
        OSStatus status = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route), &audio_route);
        if (status!=0) { printf(" AudioSessionSetProperty ERROR!"); }
    }
}

void safeRelease(NSObject **object) {
    if (*object!=nil) {
        [*object release];
        *object = nil;
    }
}

//yong removed 8. 13 : #import "OscilographViewController.h"

#define SAMPLE_RATE 22050 //22050 //11025 //44100
#define FRAMESIZE  512 //512 //256 //1024 //512 //256
#define NUMCHANNELS 2 //2

#define kOutputBus 0
#define kInputBus 1

SuperpoweredCompressor compressor125(SAMPLE_RATE);
SuperpoweredCompressor compressor250(SAMPLE_RATE);
SuperpoweredCompressor compressor500(SAMPLE_RATE);
SuperpoweredCompressor compressor1K(SAMPLE_RATE);
SuperpoweredCompressor compressor2K(SAMPLE_RATE);
SuperpoweredCompressor compressor4K(SAMPLE_RATE);
SuperpoweredCompressor compressor8K(SAMPLE_RATE);
BOOL equalizerON = NO;
BOOL noiseSuppressionON = YES;

Float32 mainGain;
//
Float32 homeWorkBuffer[FRAMESIZE*NUMCHANNELS];


Equalizer10Band homeTheEqualizer10;

#include "speex_echo.h"
#include "speex_preprocess.h"
SpeexPreprocessState *preprocessState;

#define TEMP_BUFFER_FRAME_SIZE  5120
Float64 temporaryBufferDouble[TEMP_BUFFER_FRAME_SIZE];

spx_int16_t denoiseInt16Buffer[TEMP_BUFFER_FRAME_SIZE];


/* noise 제거 */

#pragma mark FFT
#import "FFTHelper.h"

FFTHelperRef *homefftHelper;

Float32 maxValue;

#define CHANNEL_OUTPUT_LEFT     1
#define CHANNEL_OUTPUT_RIGHT    2
#define CHANNEL_OUTPUT_STEREO   3
char channelToOutput = CHANNEL_OUTPUT_STEREO;

const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Float32 homefrequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}

static Float32 homevectorMaxValueACC32(Float32 *vector, unsigned long size, long step) {
    Float32 maxVal;
    vDSP_maxv(vector, step, &maxVal, size);
    return maxVal;
}

static Float32 homevectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
}
#pragma mark Compress
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 파라미터 추가
// wet ,  hpCutOffHz ??
// inputGainDb / outputGaingDb 최대값은 17~18선에서 하울링 발생하지 않음.
bool compress(Float32* homeWorkBuffer, SuperpoweredCompressor *compressor){
//    compressor.inputGainDb = 24.0f;
//    compressor.enable(TRUE);

//        dispatch_async(dispatch_get_main_queue(), ^{
//              compressor->process(homeWorkBuffer, homeWorkBuffer, 512);
//        });
//    return TRUE;
    if(compressor->process(homeWorkBuffer, homeWorkBuffer, 512)) {
        //     1.outputGainDb /  inputGainDb manGain값 넣어 주기.
        //     2. hzCutOffHz 및 wet 에 관해 문의하기
        //        printf("frame Size : %d\n",(unsigned int)frameSize);
        //          NSLog(@"compressor success");
//                        compressor.inputGainDb = 15.0f;
//        compressor.outputGainDb = 18.0f;
//        compressor.wet = 0.0f;
        //                compressor.ratio = 10.0f;
        //                compressor.thresholdDb = -20.0f;
        //                compressor.hpCutOffHz = 258.0f;
        //            printf("inputGainDb : %f\n",compressor.inputGainDb);
        //            printf("outputGainDb : %f\n",compressor.outputGainDb);
        //            printf("wet : %f\n",compressor.wet);
        //            printf("attackSec : %f\n",compressor.attackSec);
        //            printf("releaseSec : %f\n",compressor.releaseSec);
        //            printf("ratio : %f\n",compressor.ratio);
        //            printf("thresholdDb : %f\n",compressor.thresholdDb);
        //            printf("hpCutOffHz : %f\n",compressor.hpCutOffHz);
        return true;
        
    }
    else {
      NSLog(@"falied");
        return false;
    }
}
double compareDecibels(double currentDecibel, Float32 hearingTestDecibel){
    double selectedDecibel = currentDecibel;
    printf("compare : current : %f    TestDecibel : %f\n",currentDecibel,hearingTestDecibel);
    if(currentDecibel >= hearingTestDecibel) {
        printf("current : %f hearing : %f\n",currentDecibel,hearingTestDecibel);
//        return selectedDecibel;
        return 0.0f;
    }
    else{
        selectedDecibel = fabsf(hearingTestDecibel) + selectedDecibel;
        return std::abs(selectedDecibel);
    }
}

const UInt32 homeWindowLength = SAMPLE_RATE;
Float32 *homeWindowBuffer= NULL;

#define DBOFFSET -74.0
#define LOWPASSFILTERTIMESLICE .001


//volatile BOOL mainOnOffFlag = YES;
volatile BOOL OnOffFlag = YES;


#pragma mark MAIN CALLBACK
void monoAudioCallback( Float32 * buffer, UInt32 frameSize, void * userData )
{
    
    
    //measuring time of this callback execution.
    //    //    NSTimeInterval interval1 = [NSDate timeIntervalSinceReferenceDate];
    
    
    

//    printf("compareDecibels Test : %f\n",compareDecibels(-20.17293719, -14.1782937));
    Float32 zero = 0;
    vDSP_vsadd(buffer, 1, &zero, homeWorkBuffer, 1, frameSize*NUMCHANNELS); //copy buffer to workBuffer  1. 작업버퍼에 복사,
    memset(buffer, 0, sizeof(Float32)*frameSize*NUMCHANNELS);           //clear buffer with 0
    
    
    /* 노이즈 제거 */
    const double multiplier = INT16_MAX; // /max;
    
    if (noiseSuppressionON) {
        vDSP_vspdp(homeWorkBuffer, 1, temporaryBufferDouble, 1, frameSize*NUMCHANNELS);
        //convert to int16
        vDSP_vsmulD (temporaryBufferDouble, 1, &multiplier, temporaryBufferDouble, 1, frameSize*NUMCHANNELS);
        vDSP_vfix16D(temporaryBufferDouble, 1, denoiseInt16Buffer, 1, frameSize*NUMCHANNELS);
        
        //actual denoising
        speex_preprocess_run(preprocessState, denoiseInt16Buffer);
        
        // back to float
        double divider = INT16_MAX; // /max;
        vDSP_vflt16D(denoiseInt16Buffer, 1, temporaryBufferDouble, 1, frameSize*NUMCHANNELS);
        vDSP_vsdivD(temporaryBufferDouble, 1, &divider, temporaryBufferDouble, 1, frameSize*NUMCHANNELS);
        //convert from double to float
        vDSP_vdpsp(temporaryBufferDouble, 1, homeWorkBuffer, 1, frameSize*NUMCHANNELS);
        //=================================================
    }

//    compressor.process(homeWorkBuffer, homeWorkBuffer, frameSize*NUMCHANNELS);

    //EQUALIZER ========이퀄라이저 적용 ================
    if (equalizerON) {
        for(int i=0; i<frameSize*NUMCHANNELS; i++)  {
            homeWorkBuffer[i] = equalizer10BandTick(&homeTheEqualizer10, homeWorkBuffer[i]); // 이 부분은 델리게이트로 equalizer10BandTick가 리턴하는 값만 가지고 오자.

        }
    }
    Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
    Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude ; // We'll need
    // these in the low-pass filter
    
    Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
    //////////////////////////////////////
    
    const Float32 S = 0.25;  //?
    const Float32 compression = 20;  //압축률 ?
    
    for (UInt32 i=0; i<frameSize*NUMCHANNELS; i++) {
        /**********        dB beign           **********/
        //     Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample,
        /*****************/
        //        Float32 sample = buffer[i];
        Float32 absSample = fabsf(homeWorkBuffer[i]);
        // get its amplitude's absolute value.
        
        // Step 3: for each sample's absolute value, run it through a simple low-pass filter
        // Begin low-pass filter
        
//     LOWPASSFILTERIMESLICE .001
//     DBOFFSET 74.0
//     DBL_MAX   ??
        currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absSample + (1.0 - LOWPASSFILTERTIMESLICE) * previousFilteredValueOfSampleAmplitude;
//        previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
//        Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
//        
//        // End low-pass filter
//        
//        /*
//         double sum=0;
//         for (int i = 0; i < readSize; i++) {
//         double y = audioBuffer[i] / 32768.0;
//         sum += y * y;
//         }
//         double rms = Math.sqrt(sum / readSize);
//         dbAmp=20.0 *Math.log10(rms);
//         
//         */
//
//        Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
////        Float32 sampleDB = 20.0*log10(currentFilteredValueOfSampleAmplitude) + DBOFFSET;
//        
//        // Step 4: for each sample's filtered absolute value, convert it into decibels
//        // Step 5: for each sample's filtered absolute value in decibels,
//        // add an offset value that normalizes the clipping point of the device to zero.
////        NSLog(@"before sampleDB %@",[NSString stringWithFormat:@"%f",sampleDB]);
//        if((sampleDB == sampleDB) && (sampleDB != -DBL_MAX)) { // if it's a rational number and
//            // isn't infinite
//            
//            if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value
//            // you find.
//            decibels = peakValue; // final value
//        } // 이 if  문은 사실상 필요 없는 부분 아닐까?
//        /////////////////// dB end /////////////////
//
////powf(x , y) : x 의 y 제곱값 계산
////        printf("powf(absSample, (1.0/compression)) :%f \n",powf(absSample, (1.0/compression)));
////        printf("powf(S, (1.0-1.0/compression) : %f\n",powf(S, (1.0-1.0/compression)));
//        if ( absSample < 0 || absSample  > 1 ) printf("absSample= %f", absSample);
//        
//        if (absSample>S) {   //여기서 S는 Threshold 값? 즉 S 보다 소리가 크면 압축해서 홈버퍼에 넣는 다는 것?
//            absSample = powf(absSample, (1.0/compression)) * powf(S, (1.0-1.0/compression) );
//        }
//        
//        if  (homeWorkBuffer[i]>0)   { homeWorkBuffer[i] = absSample; } else
//        { homeWorkBuffer[i] = -1*absSample;}
        
    }
//    printf("decibels : %f\n",(20.0*log10(currentFilteredValueOfSampleAmplitude / 32767))+abs(DBOFFSET));
//    p1 에 p3을 계산해서 p3에 저장  p5는 계산해서 넣을 크기?
    vDSP_vsmul(homeWorkBuffer, 1, &mainGain, homeWorkBuffer, 1, frameSize*NUMCHANNELS); // 뭐하는 함수야?

    //======================================================

    
    //LOOPBACK detection ===============================
    //root mean square
    const Float32 largeVolumeThreshold = 0.8;
    
    static Float32 helperBuffer[FRAMESIZE*NUMCHANNELS*2];
    memmove(helperBuffer, homeWorkBuffer, frameSize*NUMCHANNELS*sizeof(Float32));

    Float32 meanValue;
    vDSP_vsq (helperBuffer, 1, helperBuffer, 1, frameSize*NUMCHANNELS);
    vDSP_meanv(helperBuffer, 1, &meanValue, frameSize*NUMCHANNELS);
    Float32 squareRoot = sqrtf(meanValue);
    __block Float32 percenVolume = squareRoot/largeVolumeThreshold; // max 1.0
    dispatch_async(dispatch_get_main_queue(), ^{ //to avoid waiting for method call and UI changes.
        //        [mainController setRedWaveIconAlpha:percenVolume];
        
        static UInt32 overThresholdCounter;
        if  (percenVolume>1.0) { overThresholdCounter++; } else { overThresholdCounter = 0; }
        if  (overThresholdCounter>8) { [mainController lowMainGainTwice];
            overThresholdCounter = 0; }
    });
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    if (homeWindowBuffer==NULL) { homeWindowBuffer = (Float32*) malloc(sizeof(Float32)*homeWindowLength); }
    vDSP_blkman_window(homeWindowBuffer, frameSize*NUMCHANNELS, 0);
    vDSP_vmul(homeWorkBuffer, 1, homeWindowBuffer, 1, homeWindowBuffer, 1, frameSize*NUMCHANNELS); //using window buffer to store windowed data just to keep original data untouched
    
    Float32 *fftData = computeFFT(homefftHelper, homeWindowBuffer, frameSize*NUMCHANNELS); //여기서 windowBuffer가 타임도메인데이타임.
    
    

    
    
    
    
    
    //   printf("Y=FFT(x) = %g \n ",   *fftData );
    
    
    
    
    
    
    
    Float32 fftMaxVal = 0; //초기값 초기화
    UInt32 length = frameSize/2.0;
    
    //     fftData[0] = 0.0;  //초기값
    //  vDSP_maxv(fftData, 1, &fftMaxVal, length);  //fftMaxVal를 번지값으로 넘겨 받으면, 값을 받는다. length도 받는다.
    //printf("결과값:  fftMaxVal = %g \n ",   fftMaxVal  );
    
    //가장 강한 주파수를 가져오는 함수
    /********************* strongestFrequencyHZ(windowBuffer, fftHelper, frameSize, fftData ); *****************************************************/
    //중복   Float32 *fftData = computeFFT(fftHelper, buffer, frameSize);
    //   fftData[0] = 0.0;
    //   unsigned long length = frameSize/2.0;
    //중복      unsigned long length = ( frameSize*NUMCHANNELS )/2.0; //변경 //길이가, 프레임사이즈 * 2 인지 아닌지 ?
    
    //   Float32 max = 0;
    unsigned long maxIndex = 0;
    
    fftMaxVal = homevectorMaxValueACC32_index(fftData, length, 1, &maxIndex);  //벡터데이터, 길이  넣어주고,  최대인덱스와 실수 max값 가져온다.

    // printf("\n결과값:  max = %g , maxIndex= %d\n ",   fftMaxVal, maxIndex ); //fftMaxVal과 max는 결과가 같다.
    
    /* static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
     Float32 maxVal;
     vDSP_maxvi(vector, step, &maxVal, outIndex, size);  // Maximum value of vector, with index
     
     유사함: vDSP_maxv(fftData, 1, &fftMaxVal, length);  //fftMaxVal를 번지값으로 넘겨 받으면, 값을 받는다. length도 받는다.
     
     return maxVal;
     } */
    
    HZType typeTemp;
    typeTemp = hz250;

//    NSLog(@"typeTemp : %@",[NSString stringWithFormat:@"%u",typeTemp]);
//    NSLog(@"typeTemp : %@",[NSString stringWithFormat:@"%u",hz8k]);
//    NSLog(@"amplitude : %@",[NSString stringWithFormat:@"%f",currentFilteredValueOfSampleAmplitude]);
//    NSLog(@"db : %@",[NSString stringWithFormat:@"%f",20.0*log10(currentFilteredValueOfSampleAmplitude)]);
    double currentDecibel  = 20.0*log10(currentFilteredValueOfSampleAmplitude);
    // NSLog(@" max = %f", max);
    // if (freqValue!=NULL) { *freqValue = max; }
    Float32 HZ = homefrequencyHerzValue(maxIndex, length, NyquistMaxFreq); // 마이크로 들어 오는 주파수
//    compressor.ratio = 8.0f;
//    printf("ratio : %f\n",compressor.ratio);
//    주파수 구분 ( 추후에 좀더 디테일하게)
//    125 250 500 1k 2k 4k 8k
//     (superpowered가 된다는 가정하에) 각 주파수마다 셋팅을 달리하여 압축.
    
//    printf("currentDecibels : %f\n",currentDecibel);
    if(HZ  >= 8000){
//        compressor8K.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz8k]);
//        NSLog(@"8000 up");
//        dispatch_async(dispatch_get_main_queue(), ^{
         compress(homeWorkBuffer,&compressor8K);
//        });
        
    }else if(HZ >= 4000){
//        compressor4K.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz4k]);
//        dispatch_async(dispatch_get_main_queue(), ^{
         compress(homeWorkBuffer,&compressor4K);
//        });
//        NSLog(@"4000 up");
        
    }else if(HZ >= 2000){
//        compressor2K.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz2k]);
//        dispatch_async(dispatch_get_main_queue(), ^{
         compress(homeWorkBuffer,&compressor2K);
//        });
//        NSLog(@"2000 up");
        
    }else if(HZ >= 1000){
//        compressor1K.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz1K]);
//        dispatch_async(dispatch_get_main_queue(), ^{
         compress(homeWorkBuffer,&compressor1K);
//        });
//        NSLog(@"1000 up");
        
    }else if(HZ >= 500){
//        compressor500.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz500]);
//        dispatch_async(dispatch_get_main_queue(), ^{
         compress(homeWorkBuffer,&compressor500);
//        });
//        NSLog(@"500 up");
        
    }else if(HZ >= 250){
//        printf("currentDecibels : %f\n",currentDecibel);
//        printf("average : %f\n",[mainController getAverageValue:hz250]);
//       printf("compare : %f\n",compareDecibels(currentDecibel, [mainController getAverageValue:hz250]));
//        compressor250.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz250]);
//        compressor.enable(TRUE);
//        compressor.outputGainDb = 24.0f;
//        dispatch_async(dispatch_get_main_queue(), ^{
        compress(homeWorkBuffer,&compressor250);
//        });
//        printf("outputGain : %f\n",compressor.outputGainDb);
//        NSLog(@"250 up");
        
    }else{
//        compressor.outputGainDb = compareDecibels(currentDecibel, );
//        NSLog(@"120 up");
//        compressor125.outputGainDb = compareDecibels(currentDecibel, [mainController getAverageValue:hz125]);
//        dispatch_async(dispatch_get_main_queue(), ^{
        compress(homeWorkBuffer,&compressor125);
        printf("ratio : %f\n",compressor125.ratio);
        printf("threshold : %f\n",compressor125.thresholdDb);
//        });
    }
    //  printf("Hz:  %f", HZ  );
    //return HZ;
    // updateHz(Float32 HZ);
    
    pointerData = [[PointerData alloc]init];
    
    [pointerData setData:fftData];
    NSNumber    *maxVal = [NSNumber numberWithFloat:fftMaxVal];
//    NSNumber    *data = [NSNumber numberWithFloat:*fftData];
    NSNumber     *leng = [NSNumber numberWithFloat:length];
//
    dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    maxVal,@"fftMaxVal",
                    pointerData,@"fftData",
                    leng,@"length", nil];

    /**************************************************************************/
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        /* x, y축 그리기 */
//        [homeOsciView setDataMaxValue:fftMaxVal minValue:0];  //최소값 0, 최대값 fftMaxVal로 설정
//        [homeOsciView addAndDrawData:fftData lenght:length];
        //        [homeOsciView addAndDrawUILabelHz: HZ];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fourthViewSubmit"
                                                            object:mainController
                                                          userInfo:dataDict];
//        if(mainController.delegate != nil){
//            [mainController.delegate drawGraphMaxVal:fftMaxVal andfftData:fftData andLenth:length];
//        }
//    });
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    
    vDSP_vsadd(homeWorkBuffer, 1, &zero, buffer, 1, frameSize*NUMCHANNELS); //copy workBuffer back to buffer  //작업버퍼를 다시 버퍼에 복사
    
    if  (headphonesConnected==NO) { memset(buffer, 0, frameSize*NUMCHANNELS*sizeof(Float32)); } //headphones.
}


@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad { // ratio /  threshold 설정해주기. plist로 저장 안되었을 시 기본값으로 세팅.
    [super viewDidLoad];
    //    OnOffFlag = YES;
    
    printf("home viewDidload \n");
    
    NSLog(@"csv delegate set");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleeqViewNotif:)
                                                 name:@"eqViewNotif"
                                               object:nil];
    //노티피 등록 _ CompressSetupViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(compressSetupNotif:)
                                                 name:@"compressSetupNotif"
                                               object:nil];
    //    PhonesViewController *pvController = [[PhonesViewController alloc]init];
//    pvController.delegate = self;
//    SuperpoweredCompressor compressor(SAMPLE_RATE);
//    SuperpoweredCompressor compressor(SAMPLE_RATE);
    if([self completeLoadTestResult]) NSLog(@"data Load Success"); // 청력검사 결과 불러온 후 멤버변수
    else NSLog(@"data Load Failed");                                                // leftResultArray, rightResultArray, averageResultArray에 저장.
    [self computeAverageDb];                                                            // left : 왼쪽 청력 결과 right : 오른쪽 청력 결과 average  : 왼 + 오 결과의 평균
//    printf("average : %f\n",[self getAverageValue:hz125]);
//    printf("average : %f\n",[self getAverageValue:hz250]);
//    printf("average : %f\n",[self getAverageValue:hz500]);
    [self initCompressor];
    
//    compressor.inputGainDb = 24.0f;
//    compressor.outputGainDb = 24.0f;
//    compressor.wet = 0.0f;
//    compressor.ratio = 10.0f;
//    compressor.thresholdDb = -20.0f;
//    compressor.hpCutOffHz = 250.0f;
//
//    NSLog(@"after compressor");
//    printf("inputGainDb : %f\n",compressor.inputGainDb);
//    printf("outputGainDb : %f\n",compressor.outputGainDb);
//    printf("wet : %f\n",compressor.wet);
//    printf("attackSec : %f\n",compressor.attackSec);
//    printf("releaseSec : %f\n",compressor.releaseSec);
//    printf("ratio : %f\n",compressor.ratio);
//    printf("thresholdDb : %f\n",compressor.thresholdDb);
//    printf("hpCutOffHz : %f\n",compressor.hpCutOffHz);
    
    mainController = self;
    backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    
    initializeEqualizer10Band(&homeTheEqualizer10, SAMPLE_RATE,1);
    
    equalizerON = YES;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    homeOsciView = [[OsciGraph alloc] initWithFrame:CGRectMake(0, 0, homeGraphViewContainer.frame.size.width, homeGraphViewContainer.frame.size.height)];
//    homeOsciView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징
//    /****  여기서 뷰 연결안하고 바로 그림 */
//    
//    //    osciView.layer.mask = mainGraphCircle.layer;
//    //yong : 그냥 사각형, 원이 아닌 용도로 제거    osciView.layer.cornerRadius = 20;
//    homeOsciView.layer.masksToBounds = YES;
//    homeOsciView.currentMode = MODE_FREQ_DOMAIN;
//    [homeGraphViewContainer addSubview:  [homeOsciView autorelease]];
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
  
    
    
    [gainSlider setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
    
    homefftHelper = FFTHelperCreate(FRAMESIZE * NUMCHANNELS);
    
    mainGain = 1.0;
    noiseSuppressionON = YES;
    
    preprocessState = speex_preprocess_state_init(FRAMESIZE * NUMCHANNELS, SAMPLE_RATE);
    int denoiseVal = 1;
    speex_preprocess_ctl(preprocessState, SPEEX_PREPROCESS_SET_DENOISE, &denoiseVal);
    
    int AGC_val = 2;
    speex_preprocess_ctl(preprocessState, SPEEX_PREPROCESS_SET_AGC, &AGC_val);
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth  error:&error];
    if  (error) { NSLog(@" error setting audio session category! "); return; }

    
    
    [self initMomuAudio];
    
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
    [self headphonesConnected:isHeadsetPluggedIn()];
    
    [pointerData autorelease];
    

}
-(void)initCompressor
{
    compressor125.enable(TRUE);
    compressor250.enable(TRUE);
    compressor500.enable(TRUE);
    compressor1K.enable(TRUE);
    compressor2K.enable(TRUE);
    compressor4K.enable(TRUE);
    compressor8K.enable(TRUE);
    
//    compressor125.thresholdDb = -40.0f;
//    compressor250.thresholdDb = -40.0f;
//    compressor500.thresholdDb = -40.0f;
//    compressor1K.thresholdDb = -40.0f;
//    compressor2K.thresholdDb = -40.0f;
//    compressor4K.thresholdDb = -40.0f;
//    compressor8K.thresholdDb = -40.0f;
    
//    
//    compressor125.hpCutOffHz = 125.0f;
//    compressor250.hpCutOffHz = 250.0f;
//    compressor500.hpCutOffHz = 500.0f;
//    compressor1K.hpCutOffHz = 1000.0f;
//    compressor2K.hpCutOffHz = 2000.0f;
//    compressor4K.hpCutOffHz = 4000.0f;
//    compressor8K.hpCutOffHz = 8000.0f;
    [self compressorThresholdSetup:-40.0f];
    
    [self compressorGainSetup];
}
-(void)compressorThresholdSetup:(Float32)thresholdValue{
    
    compressor125.thresholdDb = thresholdValue;
    compressor250.thresholdDb = thresholdValue;
    compressor500.thresholdDb = thresholdValue;
    compressor1K.thresholdDb = thresholdValue;
    compressor2K.thresholdDb = thresholdValue;
    compressor4K.thresholdDb = thresholdValue;
    compressor8K.thresholdDb = thresholdValue;
    
}
-(void)compressorRatioSetup:(Float32)ratio{
    compressor125.ratio = ratio;
    compressor250.ratio = ratio;
    compressor500.ratio = ratio;
    compressor1K.ratio = ratio;
    compressor2K.ratio = ratio;
    compressor4K.ratio = ratio;
    compressor8K.ratio = ratio;
}
-(void)compressorGainSetup
{
//    compressor125.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz125]);
//    compressor250.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz250]);
//    compressor500.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz500]);
//    compressor1K.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz1K]);
//    compressor2K.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz2k]);
//    compressor4K.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz4k]);
//    compressor8K.outputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz8k]);
    
    compressor125.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz125]);
    compressor250.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz250]);
    compressor500.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz500]);
    compressor1K.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz1K]);
    compressor2K.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz2k]);
    compressor4K.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz4k]);
    compressor8K.inputGainDb = compareDecibels(-50.0f, [self getAverageValue:hz8k]);

//    compressor125.outputGainDb = 15.0f;
//    compressor250.outputGainDb = 15.0f;
//    compressor500.outputGainDb = 15.0f;
//    compressor1K.outputGainDb = 15.0f;
//    compressor2K.outputGainDb = 15.0f;
//    compressor4K.outputGainDb = 15.0f;
//    compressor8K.outputGainDb = 15.0f;

    
//     printf("125 : %f\n",compressor125.outputGainDb);
//     printf("250 : %f\n",compressor250.outputGainDb);
//     printf("500 : %f\n",compressor500.outputGainDb);
//     printf("1K : %f\n",compressor1K.outputGainDb);
//     printf("2K : %f\n",compressor2K.outputGainDb);
//     printf("4K : %f\n",compressor4K.outputGainDb);
//     printf("8K : %f\n",compressor8K.outputGainDb);
    
    
    printf("125 : %f\n",compressor125.inputGainDb);
    printf("250 : %f\n",compressor250.inputGainDb);
    printf("500 : %f\n",compressor500.inputGainDb);
    printf("1K : %f\n",compressor1K.inputGainDb);
    printf("2K : %f\n",compressor2K.inputGainDb);
    printf("4K : %f\n",compressor4K.inputGainDb);
    printf("8K : %f\n",compressor8K.inputGainDb);
}
-(void)viewDidAppear:(BOOL)animated{
    printf("home index : %d\n",self.tabBarController.selectedIndex);
    if(OnOffFlag){
        printf("State is On\n");
        
    homefftHelper = FFTHelperCreate(FRAMESIZE * NUMCHANNELS);
    preprocessState = speex_preprocess_state_init(FRAMESIZE * NUMCHANNELS, SAMPLE_RATE);
    int denoiseVal = 1;
    speex_preprocess_ctl(preprocessState, SPEEX_PREPROCESS_SET_DENOISE, &denoiseVal);
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRootPath = [documentPath objectAtIndex:0];
    
    NSString *stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"EQValue.plist"];
    
    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    
    if(eqValueDic){
        NSLog(@"homeViewController : Data Load Success");
        
        NSArray *bandValueArray2 = [eqValueDic objectForKey:@"bandValueArray"];
        NSLog(@"load value is %@",bandValueArray2);
        float arrayValue[10];
//        NSNumber *band1Value = [bandValueArray2 objectAtIndex:0];
//        NSNumber *band2Value = [bandValueArray2 objectAtIndex:1];
//        NSNumber *band3Value = [bandValueArray2 objectAtIndex:2];
//        NSNumber *band4Value = [bandValueArray2 objectAtIndex:3];
//        NSNumber *band5Value = [bandValueArray2 objectAtIndex:4];
//        NSNumber *band6Value = [bandValueArray2 objectAtIndex:5];
//        NSNumber *band7Value = [bandValueArray2 objectAtIndex:6];
//        NSNumber *band8Value = [bandValueArray2 objectAtIndex:7];
//        NSNumber *band9Value = [bandValueArray2 objectAtIndex:8];
//        NSNumber *band10Value = [bandValueArray2 objectAtIndex:9];
        
        arrayValue[0] = [[bandValueArray2 objectAtIndex:0] floatValue];
        arrayValue[1] = [[bandValueArray2 objectAtIndex:1] floatValue];
        arrayValue[2] = [[bandValueArray2 objectAtIndex:2] floatValue];
        arrayValue[3] = [[bandValueArray2 objectAtIndex:3] floatValue];
        arrayValue[4] = [[bandValueArray2 objectAtIndex:4] floatValue];
        arrayValue[5] = [[bandValueArray2 objectAtIndex:5] floatValue];
        arrayValue[6] = [[bandValueArray2 objectAtIndex:6] floatValue];
        arrayValue[7] = [[bandValueArray2 objectAtIndex:7] floatValue];
        arrayValue[8] = [[bandValueArray2 objectAtIndex:8] floatValue];
        arrayValue[9] = [[bandValueArray2 objectAtIndex:9] floatValue];
        

        
        loadDataAddEqualizer10Band(&homeTheEqualizer10,arrayValue);
        
    }else{
        NSLog(@"homeViewController :  EQ Data Load Failed");
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////
//    int AGC_val = 2;
//    speex_preprocess_ctl(preprocessState, SPEEX_PREPROCESS_SET_AGC, &AGC_val);
    
        // 10/15 주석
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        
//        NSError *error = nil;
//        
//        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth  error:&error];
//        if  (error) { NSLog(@" error setting audio session category! "); return; }
//        
//        
//        
//        [self initMomuAudio];
//        // 여기다가 이퀄 적용
//        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
//        [self headphonesConnected:isHeadsetPluggedIn()];
//        
//        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
        // 10/15 주석
    }else{
        printf("State is Off\n");
    }

}
-(void)computeAverageDb{ // 왼쪽 / 오른쪽 청력 청력검사 평균 값 계산
    for(int i = 0; i < 7; i++){
        averageResultArray[i] = (leftResultArray[i] + rightResultArray[i]) / 2;
    }
}
-(void)audioOnOff :(BOOL)flag{
    if(flag){
        backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
        //        [self initMomuAudio];
        [OnOffButton setImage:[UIImage imageNamed:@"mainOnOff_active"] forState:UIControlStateNormal];
        /////
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth  error:&error];
        if  (error) { NSLog(@" error setting audio session category! "); return; }
        
        
        
        [self initMomuAudio];
        // 여기다가 이퀄 적용
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
        [self headphonesConnected:isHeadsetPluggedIn()];
        
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
        /////
        NSLog(@"audio on!!");
    }else{
//        MoAudio::stop(); shutdown 안에 stop()포함 되어 있음
        MoAudio::shutdown();
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
        [OnOffButton setImage:[UIImage imageNamed:@"mainOnOff_passive"] forState:UIControlStateNormal];
        //        OnOffFlag = !OnOffFlag;
        NSLog(@"audio off");
    }

}
-(void)compressSetupNotif:(NSNotification*)notification{
    NSLog(@"homeViewController  from CompressSetupViewController notif");
    NSDictionary *compressSetup = notification.userInfo;
    NSNumber *ratio = [compressSetup objectForKey:@"compressRatio"];
    NSNumber *threshold = [compressSetup objectForKey:@"compressThreshold"];
    NSLog(@"homeViewController ratiod : %@",[NSString stringWithFormat:@"%f",ratio.floatValue]);
    NSLog(@"homeViewController threshold : %@",[NSString stringWithFormat:@"%f",threshold.floatValue]);
    
    [self compressorThresholdSetup:-40.0f * threshold.floatValue];
    [self compressorRatioSetup:ratio.floatValue];
    
    
}
- (void)handleeqViewNotif:(NSNotification *)notification {
    homeViewDic = [notification userInfo];
    NSNumber *tagValue = [homeViewDic objectForKey:@"tagValue"];
    NSNumber *band = [homeViewDic objectForKey:@"bandValue"];

    if (tagValue.intValue==1)  { homeTheEqualizer10.band1Volume = band.floatValue; }
    if (tagValue.intValue==2) { homeTheEqualizer10.band2Volume = band.floatValue; }
    if (tagValue.intValue==3) { homeTheEqualizer10.band3Volume = band.floatValue; }
    if (tagValue.intValue==4) { homeTheEqualizer10.band4Volume = band.floatValue; }
    if (tagValue.intValue==5) { homeTheEqualizer10.band5Volume = band.floatValue; }
    if (tagValue.intValue==6) { homeTheEqualizer10.band6Volume = band.floatValue; }
    if (tagValue.intValue==7) { homeTheEqualizer10.band7Volume = band.floatValue; }
    if (tagValue.intValue==8) { homeTheEqualizer10.band8Volume = band.floatValue; }
    if (tagValue.intValue==9) { homeTheEqualizer10.band9Volume = band.floatValue; }
    if (tagValue.intValue==10) { homeTheEqualizer10.band10Volume = band.floatValue; }
    
    
    equalizerON = YES;
    printf("home notif from EQView : %d   %f\n",tagValue.intValue,band.floatValue);
    
}
-(BOOL)completeLoadTestResult{
    NSDictionary *tempDic;
    if((tempDic = [self loadTestResult:LEFT])){
        NSLog(@"Load LEFT result : %@",tempDic);
        testResultArray = [tempDic objectForKey:@"dataArray"];
        NSNumber *numberFloat;
        
        for(int i = 0; i <7;i++){
            numberFloat = [testResultArray objectAtIndex:i];
            leftResultArray[i] = [numberFloat floatValue];
            printf("left %d: %f\n",i,leftResultArray[i]);
            
            //            NSLog(@"numberFloat : %@",[NSString stringWithFormat:@"%f",[numberFloat floatValue]]);
        }
        
        //        printf("count : %d\n",[testResultArray count]);
        //        [testResultArray init];
    }
    if((tempDic = [self loadTestResult:RIGHT])){
        NSLog(@"Load RIGHT result :%@",tempDic);
        testResultArray = [tempDic objectForKey:@"dataArray"];
        NSNumber *numberFloat;
        
        for(int i = 0; i<7; i++){
            numberFloat = [testResultArray objectAtIndex:i];
            rightResultArray[i] = [numberFloat floatValue];
            printf("right %d: %f\n",i,rightResultArray[i]);
            
        }
        NSLog(@"Load RIGHT result : %@",tempDic);
    }
    if(tempDic == nil){
        NSLog(@"don't have result data");
        return FALSE;
    }else{
        return TRUE;
    }
}
-(NSDictionary *)loadTestResult:(int)flag{
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRootPath = [documentPath objectAtIndex:0];
    
    //    NSString *stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"LeftHearingTestData.plist"];
    
    //    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    NSString *stringFilaPath;
    NSDictionary *eqValueDic = nil;
    switch(flag){
        case LEFT:
            stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"LeftHearingTestData.plist"];
            
            eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
            if(eqValueDic){
                NSLog(@"LeftTestData Load Success");
                NSLog(@"%@",eqValueDic);
            }else{
                NSLog(@"TestData Load Failed");
            }
            break;
        case RIGHT:
            stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"RightHearingTestData.plist"];
            eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
            
            if(eqValueDic){
                NSLog(@"RightTestData Load Success");
                NSLog(@"%@",eqValueDic);
            }else{
                NSLog(@"EQValue Load Failed");
            }
            break;
    }
    return eqValueDic;
    //    if(eqValueDic){
    //        NSLog(@"LeftTestData Load Success");
    //        NSLog(@"%@",eqValueDic);
    //    }else{
    //        NSLog(@"TestData Load Failed");
    //    }
    
    //    stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"RightHearingTestData.plist"];
    //    eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    //
    //    if(eqValueDic){
    //        NSLog(@"RightTestData Load Success");
    //        NSLog(@"%@",eqValueDic);
    //    }else{
    //        NSLog(@"EQValue Load Failed");
    //    }
    
    //    stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"EQValue.plist"];
    //    eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    //
    //    if(eqValueDic){
    //        NSLog(@"EQValue Load Success");
    //        NSLog(@"%@",eqValueDic);
    //    }else{
    //        NSLog(@"EQValue Load Failed");
    //    }
    //    
    //    return eqValueDic;
}

//PhonesViewController에서 사용하는 델리게이트 메소드
-(void)AudioOnOff:(BOOL)OnOffFlag{
    
    NSLog(@"HomeViewController : phone - home delegate");
    if(OnOffFlag) NSLog(@"flag is TRUE, Audio On");
    else NSLog(@"flag is FALSE, Audio Off");
    [self audioOnOff:OnOffFlag];
}
-(BOOL)getOnOffFlag{
    return OnOffFlag;
}
-(void)hearingTestNotif{
    
    if([self completeLoadTestResult]) NSLog(@"hearingTestNotif : data Load Success"); // 청력검사 결과 불러온 후 멤버변수
    else NSLog(@"hearingTestNotif : data Load Failed");                                                // leftResultArray, rightResultArray, averageResultArray에 저장.
    [self computeAverageDb];
    [self initCompressor];
    
}
#pragma mark SEGUE
-(IBAction)moveToHomeSegue:(UIStoryboardSegue*)segue
{
    NSLog(@"back from : %@",[segue.sourceViewController class]);
}


#pragma mark ACTIONS

- (IBAction)On_OffAction:(id)sender {
    OnOffFlag = !OnOffFlag;

    [self audioOnOff:OnOffFlag];
}
-(Float32)getAverageValue:(HZType)hzValue{
    return averageResultArray[hzValue];
}

- (IBAction)noiseButtonAction:(id)sender {
    noiseSuppressionON = !noiseSuppressionON;
    if(noiseSuppressionON){
        [eqOnOffButton setImage:[UIImage imageNamed:@"mainOnOff_active"] forState:UIControlStateNormal];
    }else{
        [eqOnOffButton setImage:[UIImage imageNamed:@"mainOnOff_passive"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(BOOL) initMomuAudio {
    bool result = false;;
    result = MoAudio::init( SAMPLE_RATE, FRAMESIZE, NUMCHANNELS, false);
    result = MoAudio::start( monoAudioCallback, NULL );
    
    if( !result ) {   NSLog( @"cannot start real-time audio!" ); }
    
    return result;
}


-(void) headphonesConnected:(BOOL) flag {
    headphonesConnected = flag;
    if (flag==YES) {
    } else {
        //        [mainGainSlider setValue:mainGainSlider.minimumValue animated:YES];
    }
}

-(void) setRedWaveIconAlpha:(Float32) value {
    //    redWavesIcon.alpha = value;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//-(void) headphonesConnected:(BOOL) flag {
//    headphonesConnected = flag;
//    if (flag==YES) {
//    } else {
//        //        [mainGainSlider setValue:mainGainSlider.minimumValue animated:YES];
//    }
//}
-(void)monoAudioCallback:(Float32)buffer andSize:(UInt32)frameSize andData :(void*)userData{
    
}

-(void) lowMainGainTwice {
    
    //    if  (mainGainSlider.tracking==YES || stetoscopeAnimationProcessing==YES) { NSLog(@" tracking YES"); return;}
    
    static BOOL isProcessing = NO;
    if  (isProcessing) { NSLog(@" processing YES"); return; }
    
    isProcessing = YES;
    const Float32 gainInitialValue = mainGain;
    
    const float stepInterval = 0.05;
    for (int i=0; i<25; i++) {
        double delayInSeconds = stepInterval*i;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            mainGain = gainInitialValue / (1.0+i/25.0) ; // slowly low the volume twice
            [gainSlider setValue:mainGain];
        });
    }//for
    
    //reset procesing flag
    double delayInSeconds = stepInterval*25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        isProcessing = NO;
    });
}
- (IBAction)gainAction:(UISlider*)sender {
    mainGain = sender.value;
}


- (void)dealloc {
    [OnOffButton release];
//    [homeGraphViewContainer release];
    //    [gainSlider release];
    [eqOnOffButton release];
    [super dealloc];
}

@end
@implementation PointerData
@synthesize fftPointer;
-(Float32*)getData{
    return self.fftPointer;
}
-(void)setData:(Float32 *)pointer{
    self.fftPointer  = pointer;
//    printf("hello\n");
}

@end
