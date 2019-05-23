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

@interface ViewController ()<XDXCameraHandlerDelegate>

@property (nonatomic, strong) XDXCameraHandler              *cameraHandler;

@property (nonatomic, strong) XDXVideoEncoder *videoEncoder;

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
    
    [self.videoEncoder configureEncoderWithWidth:1280 height:720];
}

#pragma mark - Button Action

- (IBAction)startRecord:(id)sender {
    [self.videoEncoder startVideoRecord];
}

- (IBAction)stopRecord:(id)sender {
    [self.videoEncoder stopVideoRecord];
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

@end
