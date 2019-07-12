//
//  yayavoice.h
//  MyJSGame
//
//  Created by jj043 on 16/8/7.
//
//

#import <Foundation/Foundation.h>

@interface yayavoice : NSObject
+ (BOOL)voiceInit:(NSDictionary *)dict;
+ (BOOL)voiceLogin:(NSDictionary *)dict;
+ (BOOL)voiceStart;
+ (BOOL)voiceStop;
+ (BOOL)voicePlay:(NSDictionary *)dict;
+ (BOOL)voiceupload:(NSDictionary *)dict;
+ (BOOL)yayaLoginOut;
+ (BOOL)voicePlayStop;
+ (BOOL)voiceuploadUpdated:(NSDictionary *)dict;
+ (void)initVoiceRecordAndPlayProcessAddr:(NSDictionary *)dict;
@end
