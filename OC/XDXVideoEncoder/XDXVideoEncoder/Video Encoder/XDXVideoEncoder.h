//
//  XDXVideoEncoder.h
//  XDXVideoEncoder
//
//  Created by 小东邪 on 2019/5/13.
//  Copyright © 2019 小东邪. All rights reserved.
//

#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    XDXH264Encoder = 264,
    XDXH265Encoder = 265,
} XDXVideoEncoderType;

@interface XDXVideoEncoder : NSObject

/**
 Init
 */
-(instancetype)initWithWidth:(int)width
                      height:(int)height
                         fps:(int)fps
                     bitrate:(int)bitrate
     isSupportRealTimeEncode:(BOOL)isSupportRealTimeEncode
                 encoderType:(XDXVideoEncoderType)encoderType;


/**
 Restart
 */
- (void)configureEncoderWithWidth:(int)width
                           height:(int)height;



/**
 Start encode data
 */
- (void)startEncodeDataWithBuffer:(CMSampleBufferRef)buffer
                 isNeedFreeBuffer:(BOOL)isNeedFreeBuffer;


/**
 Free resources
 */
- (void)freeVideoEncoder;


/**
 Force insert I frame
 */
- (void)forceInsertKeyFrame;

/**
 * Start / Stop record file.
 */
- (void)startVideoRecord;
- (void)stopVideoRecord;

@end

NS_ASSUME_NONNULL_END
