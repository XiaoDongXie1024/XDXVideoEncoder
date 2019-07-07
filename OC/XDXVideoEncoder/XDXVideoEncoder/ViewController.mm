//
//  ViewController.m
//  XDXVideoEncoder
//
//  Created by 小东邪 on 2019/5/13.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import "ViewController.h"
#import "XDXCameraModel.h"
#import "XDXCameraHandler.h"
#import "XDXVideoEncoder.h"
#include "log4cplus.h"

/*
 
 关于本Demo中所有不理解的代码可以通过以下文章进行学习,学习后再使用效果更佳
 
 (推荐阅读)H264, H265硬件编解码基础及码流分析: https://juejin.im/post/5ce9f36bf265da1bbd4b5084
 Github: https://github.com/XiaoDongXie1024/XDXVideoEncoder
 
 */

@interface ViewController ()<XDXCameraHandlerDelegate, XDXVideoEncoderDelegate>
{
        FILE *mVideoFile;
}
@property (nonatomic, strong) XDXCameraHandler *cameraHandler;

@property (nonatomic, strong) XDXVideoEncoder *videoEncoder;

@property (nonatomic, assign) BOOL isNeedRecord;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configurevideoEncoder];
    [self configureCamera];
    
}

#pragma mark - Init
- (void)configureCamera {
    XDXCameraModel *model = [[XDXCameraModel alloc] initWithPreviewView:self.view
                                                                 preset:AVCaptureSessionPreset1280x720
                                                              frameRate:30
                                                       resolutionHeight:720
                                                            videoFormat:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                                                              torchMode:AVCaptureTorchModeOff
                                                              focusMode:AVCaptureFocusModeContinuousAutoFocus
                                                           exposureMode:AVCaptureExposureModeContinuousAutoExposure
                                                              flashMode:AVCaptureFlashModeAuto
                                                       whiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
                                                               position:AVCaptureDevicePositionBack
                                                           videoGravity:AVLayerVideoGravityResizeAspect
                                                       videoOrientation:AVCaptureVideoOrientationLandscapeRight
                                             isEnableVideoStabilization:YES];
    
    XDXCameraHandler *handler   = [[XDXCameraHandler alloc] init];
    self.cameraHandler          = handler;
    handler.delegate            = self;
    [handler configureCameraWithModel:model];
    [handler startRunning];
    
    // Orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)configurevideoEncoder {
    
    // You could select h264 / h265 encoder.
    self.videoEncoder = [[XDXVideoEncoder alloc] initWithWidth:1280
                                                        height:720
                                                           fps:30
                                                       bitrate:2048
                                       isSupportRealTimeEncode:NO
                                                   encoderType:XDXH265Encoder]; // XDXH264Encoder
    self.videoEncoder.delegate = self;
    [self.videoEncoder configureEncoderWithWidth:1280 height:720];
}

#pragma mark - Button Action

- (IBAction)startRecord:(id)sender {
    [self.videoEncoder forceInsertKeyFrame];
    self.isNeedRecord = YES;
}

- (IBAction)stopRecord:(id)sender {
    self.isNeedRecord = NO;
}


#pragma mark - Delegate
- (void)xdxCaptureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([output isKindOfClass:[AVCaptureVideoDataOutput class]] == YES) {
        if (self.videoEncoder) {
            [self.videoEncoder startEncodeDataWithBuffer:sampleBuffer
                                        isNeedFreeBuffer:NO];
            
        }
        
    }
    
}

- (void)xdxCaptureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

#pragma mark - Decoder Delegate
- (void)receiveVideoEncoderData:(XDXVideEncoderDataRef)dataRef {
    if (dataRef->isKeyFrame) {
        if (self.isNeedRecord) {
            if (mVideoFile == NULL) {
                [self initSaveVideoFile];
                log4cplus_info("Video Encoder:", "Start video record.");
            }
            
            fwrite(dataRef->data, 1, dataRef->size, mVideoFile);
        }
    }else {
        if (self.isNeedRecord && mVideoFile != NULL) {
            fwrite(dataRef->data, 1, dataRef->size, mVideoFile);
        }else {
            if (mVideoFile != NULL) {
                fclose(mVideoFile);
                mVideoFile = NULL;
                log4cplus_info("Video Encoder:", "Stop video record.");
            }
        }
    }
}

#pragma mark - Notification
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //    NSLog(@"Curent UIInterfaceOrientation is %ld",(long)orientation);
    
    if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"Device Left");
        [self.cameraHandler adjustVideoOrientationByScreenOrientation:orientation];
    }else {
        NSLog(@"App not support");
    }
}

- (void)initSaveVideoFile{
    // write file
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy_MM_dd__HH_mm_ss";
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *path               = (NSString *)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *savePath;
    if (self.videoEncoder.encoderType == XDXH264Encoder) {
        savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.h264",dateStr]];
    }else if (self.videoEncoder.encoderType == XDXH265Encoder) {
        savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.h265",dateStr]];
    }
    
    NSLog(@"File path:%@",savePath);
    
    if( (mVideoFile = fopen([savePath UTF8String], "w+")) == NULL ){
        perror("Video Encoder: File error");
    }
}

@end
