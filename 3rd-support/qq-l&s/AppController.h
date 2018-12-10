/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <AMapLocationKit/AmapLocationKit.h>
#import <TencentOpenAPI/TencentOauth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <DTShareKit/DTOpenKit.h>
#import "XianliaoSDK_iOS/SugramApiManager.h"

@class RootViewController;

@interface AppController : NSObject <DTOpenAPIDelegate,UIApplicationDelegate,WXApiDelegate,TencentSessionDelegate,QQApiInterfaceDelegate>
{
}
+(NSString *) getRoomId;
+(void) setRoomId:(NSString *)string;
+(NSString *) getAppVersion;
+(BOOL) copyToClipboard:(NSDictionary *)dict;
+(void) jumpToGPS;
+(NSString *) getGDLocation;
+(void) requestQQLogin;
+(void) qqShareMsg:(NSDictionary *)dict;
+(void) saveToImageGallery:(NSDictionary *)dict;
+(BOOL) isIphoneX;
+(int) isDingTalkInstalled;
+(int) isDingTalkSupportOpenAPI;
+(void) openDingTalk;
+(void) dingTalkShareMsg:(NSDictionary *)dict;
+(int) isXianLiaoInstalled;
+(void) xianLiaoShareMsg:(NSDictionary *)dict;
+(int) isQQInstalled;
+(int) isDeviceCharging;
+(NSString *) getDeviceInfo;
+(NSString *) getDeviceId;
+(void)deleteDeviceId:(NSString *)idKey;
+(id)loadDeviceId:(NSString *)idKey;
+(NSString*)deviceBrandName;
+(int)isAboveIphoneX;
@property(nonatomic, readonly) RootViewController* viewController;
@property(nonatomic, strong) TencentOAuth *tencentOauth;
//@property(nonatomic, strong) AMapLocationManager *locationManager;//not used
@end
