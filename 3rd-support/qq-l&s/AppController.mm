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

#import "AppController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "jstools.h"
#import "JSONKit.h"
#import "iospay.h"
#import "yayavoice.h"
#import "Reachability.h"
#import "locationtool.h"
#import <sys/utsname.h>

#import <CoreLocation/CoreLocation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#import <Foundation/Foundation.h>
#import <Security/Security.h>

//Add TalkingData support
#include "TalkingData.h"

//Add GDMap support
const static NSString *GD_API_KEY = @"a5a67e8d34514acf5b157a122944ab76";
static NSString *QQ_API_KEY = @"101489510";

@implementation AppController

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

/************************URL Open APP**************************/
static NSString* roomid = NULL;
static NSString* replayCode = NULL;
static NSString* guildID = NULL;
static bool appIsDidEnterBackground = false;

NSString* parseUrlFromStr(NSString *string)
{
    NSError *error;
    NSString *regularStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [string substringWithRange:match.range];
        NSLog(@"isUrlType %@",substringForMatch);
        return substringForMatch;
    }
    return NULL;
}

+(int)isDeviceCharging
{
    @try {
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        if([device batteryState] == UIDeviceBatteryStateCharging || [device batteryState] == UIDeviceBatteryStateFull) {
            return 1;
        }
        else {
            return 0;
        }
    }
    @catch(NSException *e) {
        return 0;
    }
}

+(int)isQQInstalled{
    BOOL r = [QQApiInterface isQQInstalled];
    if (r) {
        NSLog(@"QQ installed yes");
        return 1;
    }
    else {
        NSLog(@"QQ installed no");
        return 0;
    }
}

+(int) isXianLiaoInstalled{
    BOOL r = [SugramApiManager isInstallSugram];
    if (r) {
        NSLog(@"XiaoLiao installed yes");
        return 1;
    }
    else {
        NSLog(@"XiaoLiao installed no");
        return 0;
    }
}

+(void) xianLiaoShareMsg:(NSDictionary *)dict
{
    NSString *shareType = [dict objectForKey:@"shareType"];
    NSString *shareText = [dict objectForKey:@"shareText"];
    NSString *shareTitle = [dict objectForKey:@"shareTitle"];
    NSString *shareDesc = [dict objectForKey:@"shareDesc"];
    NSString *shareUrl = [dict objectForKey:@"shareUrl"];
    NSString *sharePreUrl = [dict objectForKey:@"sharePreUrl"];
    
    NSLog(@"shareType-->%@", shareType);
    NSLog(@"shareText-->%@", shareText);
    NSLog(@"shareTitle-->%@", shareTitle);
    NSLog(@"shareDesc-->%@", shareDesc);
    NSLog(@"shareUrl-->%@", shareUrl);
    NSLog(@"sharePreUrl-->%@", sharePreUrl);
    
    if([shareType isEqualToString:@"shareText"])
    {
        SugramShareTextObject *textObject = [[SugramShareTextObject alloc] init];
        //textObject.title = @"title";
        textObject.text = shareText;
        [SugramApiManager share:textObject fininshBlock:^(SugramShareCallBackType callBackType) {
            NSLog(@"callBackType:%ld", (long)callBackType);
        }];
    }
    else if([shareType isEqualToString:@"shareLocalImg"]){
        SugramShareImageObject *imageObject = [[SugramShareImageObject alloc] init];
        imageObject.imageData = [NSData dataWithContentsOfFile:sharePreUrl];
        [SugramApiManager share:imageObject fininshBlock:^(SugramShareCallBackType callBackType) {
            NSLog(@"callBackType:%ld", (long)callBackType);
        }];
    }
    else if([shareType isEqualToString:@"shareUrl"]){
        SugramShareGameObject *game = [[SugramShareGameObject alloc] init];
        game.roomToken = @"null";
        game.roomId = shareUrl;
        game.title = shareTitle;
        game.text = shareDesc;
        game.imageUrl = sharePreUrl;
        game.androidDownloadUrl = @"https://fir.im/ywglzp1";
        game.iOSDownloadUrl = @"https://fir.im/ywglzp2";
        //game.imageData = [self imageData];
        [SugramApiManager share:game fininshBlock:^(SugramShareCallBackType callBackType) {
            NSLog(@"callBackType:%ld", (long)callBackType);
        }];
    }
    else {
        //默认WebImage
        SugramShareImageObject *imageObject = [[SugramShareImageObject alloc] init];
        imageObject.imageUrl = sharePreUrl;
        [SugramApiManager share:imageObject fininshBlock:^(SugramShareCallBackType callBackType) {
            NSLog(@"callBackType:%ld", (long)callBackType);
        }];
    }
}

+(int) isDingTalkInstalled{
    BOOL r = [DTOpenAPI isDingTalkInstalled];
    if (r) {
        NSLog(@"DingTalk installed yes");
        return 1;
    }
    else {
        NSLog(@"DingTalk installed no");
        return 0;
    }
}

+(int) isDingTalkSupportOpenAPI{
    BOOL r = [DTOpenAPI isDingTalkSupportOpenAPI];
    if (r) {
        NSLog(@"DingTalkOpenAPI installed yes");
        return 1;
    }
    else {
        NSLog(@"DingTalkOpenAPI installed no");
        return 0;
    }
}

+(void) openDingTalk{
    [DTOpenAPI openDingTalk];
}

+(void) dingTalkShareMsg:(NSDictionary *)dict
{
    NSString *shareType = [dict objectForKey:@"shareType"];
    NSString *shareText = [dict objectForKey:@"shareText"];
    NSString *shareTitle = [dict objectForKey:@"shareTitle"];
    NSString *shareDesc = [dict objectForKey:@"shareDesc"];
    NSString *shareUrl = [dict objectForKey:@"shareUrl"];
    NSString *sharePreUrl = [dict objectForKey:@"sharePreUrl"];
    
    NSLog(@"shareType-->%@", shareType);
    NSLog(@"shareText-->%@", shareText);
    NSLog(@"shareTitle-->%@", shareTitle);
    NSLog(@"shareDesc-->%@", shareDesc);
    NSLog(@"shareUrl-->%@", shareUrl);
    NSLog(@"sharePreUrl-->%@", sharePreUrl);
    
    if([shareType isEqualToString:@"shareText"])
    {
        DTSendMessageToDingTalkReq *sendMessageReq = [[DTSendMessageToDingTalkReq alloc] init];
        DTMediaMessage *mediaMessage = [[DTMediaMessage alloc] init];
        DTMediaTextObject *textObject = [[DTMediaTextObject alloc] init];
        textObject.text = shareText;
        mediaMessage.mediaObject = textObject;
        sendMessageReq.message = mediaMessage;

        BOOL result = [DTOpenAPI sendReq:sendMessageReq];
        if (result)
        {
            NSLog(@"DT:Text 发送成功.");
        }
        else
        {
            NSLog(@"DT:Text 发送失败.");
        }
    }
    else if([shareType isEqualToString:@"shareLocalImg"]){
        DTSendMessageToDingTalkReq *sendMessageReq = [[DTSendMessageToDingTalkReq alloc] init];
        DTMediaMessage *mediaMessage = [[DTMediaMessage alloc] init];
        DTMediaImageObject *imageObject = [[DTMediaImageObject alloc] init];
        imageObject.imageData = [NSData dataWithContentsOfFile:sharePreUrl];
        //imageObject.imageURL = sharePreUrl;
        mediaMessage.mediaObject = imageObject;
        sendMessageReq.message = mediaMessage;
        BOOL result = [DTOpenAPI sendReq:sendMessageReq];
        if (result)
        {
            NSLog(@"DT:Image 发送成功.");
        }
        else
        {
            NSLog(@"DT:Image 发送失败.");
        }
    }
    else if([shareType isEqualToString:@"shareUrl"]){
        DTSendMessageToDingTalkReq *sendMessageReq = [[DTSendMessageToDingTalkReq alloc] init];
        DTMediaMessage *mediaMessage = [[DTMediaMessage alloc] init];
        DTMediaWebObject *webObject = [[DTMediaWebObject alloc] init];
        webObject.pageURL = shareUrl;
        mediaMessage.title = shareTitle;
        mediaMessage.thumbURL = sharePreUrl;
        // Or Set a image data which less than 32K.
        // mediaMessage.thumbData = UIImagePNGRepresentation([UIImage imageNamed:@"open_icon"]);
        mediaMessage.messageDescription = shareDesc;
        mediaMessage.mediaObject = webObject;
        sendMessageReq.message = mediaMessage;
        
        BOOL result = [DTOpenAPI sendReq:sendMessageReq];
        if (result)
        {
            NSLog(@"DT:URL 发送成功.");
        }
        else
        {
            NSLog(@"DT:URL 发送失败.");
        }
    }
    else {
        //默认WebImage
        DTSendMessageToDingTalkReq *sendMessageReq = [[DTSendMessageToDingTalkReq alloc] init];
        DTMediaMessage *mediaMessage = [[DTMediaMessage alloc] init];
        DTMediaImageObject *imageObject = [[DTMediaImageObject alloc] init];
        imageObject.imageData = [NSData data];
        imageObject.imageURL = sharePreUrl;
        mediaMessage.mediaObject = imageObject;
        sendMessageReq.message = mediaMessage;
        
        BOOL result = [DTOpenAPI sendReq:sendMessageReq];
        if (result)
        {
            NSLog(@"DT:Image 发送成功.");
        }
        else
        {
            NSLog(@"DT:Image 发送失败.");
        }
    }
}

+(void)deleteDeviceId:(NSString *)idKey {
    NSString *saveKeyTag = @"com.sevenjzc.ywglzp";
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,
                                          (id)kSecClass,
                                          saveKeyTag,
                                          (id)kSecAttrService,
                                          saveKeyTag,
                                          (id)kSecAttrAccount,
                                          (id)kSecAttrAccessibleAfterFirstUnlock,
                                          (id)kSecAttrAccessible,
                                          nil];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

+(id)loadDeviceId:(NSString *)idKey {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,
                                          (id)kSecClass,
                                          idKey,
                                          (id)kSecAttrService,
                                          idKey,
                                          (id)kSecAttrAccount,
                                          (id)kSecAttrAccessibleAfterFirstUnlock,
                                          (id)kSecAttrAccessible,
                                          nil];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if(SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }@catch(NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", idKey, e);
        }@finally {
            NSLog(@"Unarchive of finally");
        }
    }
    if(keyData)
        CFRelease(keyData);
    return ret;
}

+(NSString *) getDeviceId {
    NSString *saveKeyTag = @"com.sevenjzc.ywglzp";
    NSString *deviceId = (NSString *)[AppController loadDeviceId:saveKeyTag];
    //NSLog(@"从Keychain里获得的CFUUID %@", deviceId);
    if(!deviceId || [deviceId isEqualToString:@""] || [deviceId isKindOfClass:[NSNull class]]) {
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSMutableDictionary *keychainQuery2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,
                                              (id)kSecClass,
                                              saveKeyTag,
                                              (id)kSecAttrService,
                                              saveKeyTag,
                                              (id)kSecAttrAccount,
                                              (id)kSecAttrAccessibleAfterFirstUnlock,
                                              (id)kSecAttrAccessible,
                                              nil];
        SecItemDelete((CFDictionaryRef)keychainQuery2);
        [keychainQuery2 setObject:[NSKeyedArchiver archivedDataWithRootObject:idfv] forKey:(id)kSecValueData];
        SecItemAdd((CFDictionaryRef)keychainQuery2, NULL);
        deviceId = (NSString *)[AppController loadDeviceId:saveKeyTag];
    }
    NSLog(@"最终Keychain CFUUID %@", deviceId);
    return deviceId;
}

+ (NSString*)deviceBrandName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone_X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone_X";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceModel;
}

+(NSString *) getDeviceInfo{
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *sysName = [[UIDevice currentDevice] systemName];
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *brandName = [AppController deviceBrandName];
    CGRect rcScreen = [[UIScreen mainScreen] bounds];
    CGSize szScreen = rcScreen.size;
    CGFloat scrScale = [UIScreen mainScreen].scale;
    NSString *scrWidth = [NSString stringWithFormat:@"%f", szScreen.width * scrScale];
    NSString *scrHeight = [NSString stringWithFormat:@"%f", szScreen.height * scrScale];
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Language:%@", preferredLang);
    NSLog(@"deviceName %@", deviceName);
    NSLog(@"sysName %@", sysName);
    NSLog(@"sysVersion %@", sysVersion);
    NSLog(@"deviceUUID %@", deviceUUID);
    NSLog(@"deviceModel %@", deviceModel);
    NSLog(@"brandName %@", brandName);
    NSLog(@"width %@", scrWidth);
    NSLog(@"height %@", scrHeight);
    NSString *info = [NSString stringWithFormat:@"{\"product\":\"%@\", \"brand\":\"%@\", \"manufacturer\":\"%@\", \"hardware\":\"%@\", \"model\":\"%@\", \"release\":\"%@\", \"width\":\"%@\", \"height\":\"%@\", \"language\":\"%@\"}", deviceName, brandName, @"Apple", @"Apple", deviceModel, sysVersion, scrWidth, scrHeight, preferredLang];
    return info;
}

+(NSString *) getAppVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(void) setRoomId:(NSString *)string {
    if(NULL != string)
    {
        NSURL *url = [NSURL URLWithString:string];
        [AppController checkAppLink:url];
    }
}

+(NSString *) getRoomId{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if(0 < [pasteboard.string length])
    {
        NSLog(@"app has enter foreground:%@", pasteboard.string);
        [AppController setRoomId:parseUrlFromStr(pasteboard.string)];
        pasteboard.string = @"";
    }
    
    if(roomid != NULL){
        NSString * rte = [NSString stringWithFormat:@"roomid=%@", roomid];
        [roomid release];
        roomid = NULL;
        return rte;
    }
    
    if(replayCode != NULL){
        NSString * rte = [NSString stringWithFormat:@"replayCode=%@", replayCode];
        [replayCode release];
        replayCode = NULL;
        return rte;
    }
    
    if(guildID != NULL){
        NSString * rte = [NSString stringWithFormat:@"guildID=%@", guildID];
        [guildID release];
        guildID = NULL;
        return rte;
    }
    return NULL;
}

+(BOOL) copyToClipboard:(NSDictionary *)dict
{
    NSString* text = [dict objectForKey:@"text"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    return 0;
}

+(NSString *) getGDLocation {
    AMapLocationManager *locationManager = [[AMapLocationManager alloc] init];
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    [locationManager setAllowsBackgroundLocationUpdates:YES];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDetectRiskOfFakeLocation:YES];
    locationManager.locationTimeout = 8;
    locationManager.reGeocodeTimeout = 8;
    
    [locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if(error)
        {
            NSLog(@"locationError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if(error.code == AMapLocationErrorReGeocodeFailed)
            {
                return;
            }
        }
        
        NSLog(@"GD:location:%@", location);
        NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
        NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        [md setValue:latitude forKey:@"latitude"];
        NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        [md setValue:longitude forKey:@"longitude"];
        if(regeocode)
        {
            //NSLog(@"reGeocode:%@", regeocode);
            NSString *geoLocation = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@", regeocode.formattedAddress, regeocode.country, regeocode.province,
                                     regeocode.city, regeocode.district, regeocode.citycode, regeocode.adcode, regeocode.street, regeocode.number, regeocode.POIName,
                                     regeocode.AOIName];
            [md setValue:[NSString stringWithFormat:@"%@%@", regeocode.district, regeocode.street] forKey:@"geoLocation"];
        }
        [md setValue:@"location" forKey:@"type"];
        NSLog(@"%@", md);
        NSData *data = [NSJSONSerialization dataWithJSONObject:md options:NSJSONWritingPrettyPrinted error:nil];
        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [jstools sendToLuaByWxCode:ret];
        [md release];
    }];

    return @"";
}

+(void) qqShareMsg:(NSDictionary *)dict {
    NSString *text = [dict objectForKey:@"text"];
    NSString *image = [dict objectForKey:@"image"];
    NSString *absoluteImage = [dict objectForKey:@"absoluteImage"];
    NSString *utf8String = [dict objectForKey:@"url"];
    NSString *title = [dict objectForKey:@"title"];
    NSString *description = [dict objectForKey:@"description"];
    NSString *previewImgUrl = [dict objectForKey:@"previewImgUrl"];
    
    NSLog(@"text--%@", text);
    NSLog(@"image--%@", image);
    NSLog(@"absoluteImage--%@", absoluteImage);
    NSLog(@"utf8String--%@", utf8String);
    NSLog(@"title--%@", title);
    NSLog(@"description--%@", description);
    NSLog(@"previewImgUrl--%@", previewImgUrl);
    
    QQApiSendResultCode errCode;
    if(NULL != text) {
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        errCode = sent;
    }else if(NULL != image) {
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:image];
        if(NULL != absoluteImage) {
            imgPath = absoluteImage;
        }
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData 
        previewImageData:imgData 
        title:title
        description:description];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        errCode = sent;
    }else {
        //previewImageURL:[NSURL URLWithString:previewImgUrl]];
        NSString *previewImgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon-120.png"];
        NSData *previewImgData = [NSData dataWithContentsOfFile:previewImgPath];
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:utf8String] 
        title:title 
        description:description 
        previewImageData:previewImgData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        errCode = sent;
        NSLog(@"QQApiSendResultCode %d", errCode);
    }
    if(0 != errCode) {
        NSString *strErrCode = [NSString stringWithFormat:@"%d", errCode];
        NSLog(@"send message errcode: %@", strErrCode);
        NSMutableDictionary *data2;
        data2 = [[NSMutableDictionary alloc] init];
        [data2 setValue:@"qq_share" forKey:@"type"];
        [data2 setValue:[NSString stringWithFormat:@"%d", errCode] forKey:@"status"];
        [data2 setValue:@"not-ok" forKey:@"code"];
        [jstools sendToLuaByWxCode:[data2 JSONString]];
        NSLog(@"%@",@"ok");
        [data2 release];
    }
}

+(void) requestQQLogin {
    cocos2d::Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("qq_login");
}

+(BOOL) isIphoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *pf = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"**pf**:%@", pf);
    if([pf containsString:@"iPhone10"]) {
        return YES;
    }
    else {
        return NO;
    }
}

+(void) saveToImageGallery:(NSDictionary *)dict {
    UIImage *originImage = [UIImage imageWithContentsOfFile:[dict objectForKey:@"path"]];
    if (nil != originImage)
    {
        UIImageWriteToSavedPhotosAlbum(originImage, nil, nil, nil);
    }
}
    
+(void) jumpToGPS {
    NSURL *url = nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0f) {
        url=[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else {
        url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{}completionHandler:^(BOOL success) {
                NSLog(@"");
            }];
        }
    }
}

+(BOOL) checkAppLink : (NSURL *)url{
    NSString *query = url.query;
    NSLog(@"url: %@", [url absoluteString]);
    NSLog(@"url query: %@", query);
    NSArray * pairs=[query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv=[pair componentsSeparatedByString:@"="];
        if(kv.count==2)
        {
            NSString *val=[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
    }
    NSString *roomidStr=[params objectForKey:@"roomid"];
    if(roomidStr){
        NSLog(@"checkAppLink:roomidStr:%@", roomidStr);
        if(appIsDidEnterBackground){
            NSMutableDictionary *data  = [[NSMutableDictionary alloc] init];
            [data setValue:@"urlOpen" forKey:@"type"];
            NSString * roomdata = [NSString stringWithFormat:@"a%@", roomidStr];
            [data setValue:roomdata forKey:@"code"];
            [jstools sendToLuaByWxCode:[data JSONString]];
            [data release];
        }else{
            roomid = roomidStr;
            [roomid retain];
        }
    }
    NSString *replayCodeStr = [params objectForKey:@"replayCode"];
    if(replayCodeStr) {
        NSLog(@"checkAppLink:replayCode:%@", replayCodeStr);
        if(appIsDidEnterBackground){
            NSMutableDictionary *data  = [[NSMutableDictionary alloc] init];
            [data setValue:@"urlOpen" forKey:@"type"];
            NSString * roomdata = [NSString stringWithFormat:@"a%@", replayCodeStr];
            [data setValue:roomdata forKey:@"code"];
            [jstools sendToLuaByWxCode:[data JSONString]];
            [data release];
        }else{
            replayCode = replayCodeStr;
            [replayCode retain];
        }
    }

    NSString *guildIDStr = [params objectForKey:@"guildID"];
    if(guildIDStr) {
        NSLog(@"checkAppLink:guildID:%@", guildIDStr);
        if(appIsDidEnterBackground){
            NSMutableDictionary *data  = [[NSMutableDictionary alloc] init];
            [data setValue:@"urlOpen" forKey:@"type"];
            NSString * roomdata = [NSString stringWithFormat:@"a%@", guildIDStr];
            [data setValue:roomdata forKey:@"code"];
            [jstools sendToLuaByWxCode:[data JSONString]];
            [data release];
        }else{
            guildID = guildIDStr;
            [guildID retain];
        }
    }
    return YES;
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    if([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]){
        NSURL *webpageURL = userActivity.webpageURL;
        [AppController checkAppLink:webpageURL];
    }
    return YES;
}
/*************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
    
    cocos2d::Application *app = cocos2d::Application::getInstance();
    
    // Initialize the GLView attributes
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc]init];
    _viewController.wantsFullScreenLayout = YES;
    //_viewController.navigationController.interactivePopGestureRecognizer.enabled = NO;
     
     [self checkColdUpdate];

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
    }

    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden:true];
    
    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView((__bridge void *)_viewController.view);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    
    //run the cocos2d-x game scene
    app->run();
	
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    [manager requestAlwaysAuthorization];
    [manager requestWhenInUseAuthorization];
     
	[WXApi registerApp:@"wx5375851cdce0c667" withDescription:@"demo 2.0"];
     
    //TalkingData
    TDCCTalkingDataGA::onStart("0E741CE749FE4B3596F26E9028DE8C30", "iOS YWGLZP");
     
    //GDMap
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = (NSString *)GD_API_KEY;
     
    //DingDing
    [DTOpenAPI registerApp:@"dingoakifreff8eg3t6tcn"];
     
    //XianLiao
    [SugramApiManager registerApp:@"x88ZXOaO1Q9A1J3F"];
     
    //QQ
    _tencentOauth = [[TencentOAuth alloc] initWithAppId:QQ_API_KEY andDelegate:self];
     
    auto listener = cocos2d::EventListenerCustom::create("qq_login", [self](cocos2d::EventCustom* /*event*/){
        //QQ
        _tencentOauth = [[TencentOAuth alloc] initWithAppId:QQ_API_KEY andDelegate:self];
        NSArray *_permissions =  [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
        NSString *cachedToken = [_tencentOauth getCachedToken];
        NSString *cachedOpenId = [_tencentOauth getCachedOpenID];
        NSDate *cachedExpirationDate = [_tencentOauth getCachedExpirationDate];
        NSLog(@"cachedToken:%@", cachedToken);
        NSLog(@"cachedOpenId:%@", cachedOpenId);
        NSLog(@"cachedExpirationDate:%@", cachedExpirationDate);
        
        if (cachedToken && cachedOpenId && cachedExpirationDate) {
            [_tencentOauth setAccessToken:cachedToken];
            [_tencentOauth setOpenId:cachedOpenId];
            [_tencentOauth setExpirationDate:cachedExpirationDate];
            [_tencentOauth getUserInfo];
        }
        else
        {
            //调用SDK登录
            [_tencentOauth authorize:_permissions inSafari:NO];
        }
        [_tencentOauth accessToken];
        [_tencentOauth openId];
        [_tencentOauth expirationDate];
    });
    cocos2d::Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(listener, -1);
     
    [UIDevice currentDevice].batteryMonitoringEnabled = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryChargingStateChange:) name:@"UIDeviceBatteryStateDidChangeNotification" object:[UIDevice currentDevice]];
    
    return YES;
}

-(void)checkColdUpdate
{
    std::string pth = cocos2d::FileUtils::getInstance()->getWritablePath();
    NSString *nPth = [NSString stringWithCString:pth.c_str() encoding:NSASCIIStringEncoding];
    NSLog(@"pth--->%@", nPth);
    NSFileManager *fileMgr=[NSFileManager defaultManager];
    
    NSString *verPth = [NSString stringWithCString:(pth+"version.manifest").c_str() encoding:NSASCIIStringEncoding];
    NSString *proPth = [NSString stringWithCString:(pth+"project.manifest").c_str() encoding:NSASCIIStringEncoding];
    if ([fileMgr fileExistsAtPath:verPth]) {
        NSLog(@"File exists！");
        NSString *resVerOld = verPth;
        NSString *contentOld = [NSString stringWithContentsOfFile:resVerOld encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"%@",contentOld);
        id contentJsonOld = [NSJSONSerialization JSONObjectWithData:[contentOld dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSString *verNumOld = contentJsonOld[@"version"];
        int numOld = [[verNumOld stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
        NSLog(@"verion:%d", numOld);
        
        NSString *resVerNew = [[NSBundle mainBundle] pathForResource:@"res/version" ofType:@"manifest"];
        NSString *resProNew = [[NSBundle mainBundle] pathForResource:@"res/project" ofType:@"manifest"];
        NSString *contentNew = [NSString stringWithContentsOfFile:resVerNew encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"%@",contentNew);
        id contentJsonNew = [NSJSONSerialization JSONObjectWithData:[contentNew dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSString *verNumNew = contentJsonNew[@"version"];
        int numNew = [[verNumNew stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
        NSLog(@"verion:%d", numNew);
        
        if(numNew > numOld) {
            NSString *res = [NSString stringWithCString:(pth+"res").c_str() encoding:NSASCIIStringEncoding];
            NSString *src = [NSString stringWithCString:(pth+"src").c_str() encoding:NSASCIIStringEncoding];
            [fileMgr removeItemAtPath:res error:nil];
            [fileMgr removeItemAtPath:src error:nil];
            [fileMgr removeItemAtPath:verPth error:nil];
            [fileMgr removeItemAtPath:proPth error:nil];
            
            if(![fileMgr copyItemAtPath:resVerNew toPath:verPth error:nil]){
                NSLog(@"Copy failed!");
            }
            
            if(![fileMgr copyItemAtPath:resProNew toPath:proPth error:nil]){
                NSLog(@"Copy failed!");
            }
        }
    }
}

-(void)handleBatteryChargingStateChange:(id *)sender
{
    NSArray *stateArray = [NSArray arrayWithObjects:@"未开启监视电池状态",@"电池未充电状态",@"电池充电状态",@"电池充电完成",nil];
    NSLog(@"电池状态：%@", [stateArray objectAtIndex:[[UIDevice currentDevice] batteryState]]);
}

-(BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth {
    return YES;
}
    //登录成功
- (void)tencentDidLogin
{
    NSLog(@"登录完成");
    if (_tencentOauth.accessToken && 0 != [_tencentOauth.accessToken length]) {
        // 记录登录用户的OpenID、Token以及过期时间
        NSLog(@"accessToken:%@", _tencentOauth.accessToken);
        NSLog(@"openID:%@", _tencentOauth.openId);
        NSLog(@"expirationDate:%@", _tencentOauth.expirationDate);
        [_tencentOauth getUserInfo];
    } else {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}
    
-(void)getUserInfoResponse:(APIResponse *)response {
    NSLog(@"用户信息:%@", response);
    //NSLog(@"detailRetCode:%d", response.detailRetCode);
    //NSLog(@"retCode:%d", response.retCode);
    //NSLog(@"message:%@", response.message);
    //NSLog(@"errorMsg:%@", response.errorMsg);
    //NSLog(@"jsonResponse:%@", response.jsonResponse);
    
    NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
    [md setValue:@"qq_login" forKey:@"type"];
    NSString* retCodeStr = [NSString stringWithFormat:@"%d", response.retCode];
    [md setValue:retCodeStr forKey:@"retCode"];
    NSString* detailRetCodeStr = [NSString stringWithFormat:@"%d", response.detailRetCode];
    [md setValue:detailRetCodeStr forKey:@"detailRetCode"];
    [md setValue:_tencentOauth.accessToken forKey:@"accessToken"];
    [md setValue:_tencentOauth.openId forKey:@"openId"];
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString* expirationDateStr = [dtFormatter stringFromDate:_tencentOauth.expirationDate];
    [md setValue:expirationDateStr forKey:@"expirationDate"];
    [md setValue:response.message forKey:@"message"];
    NSLog(@"%@", md);
    NSData *data = [NSJSONSerialization dataWithJSONObject:md options:NSJSONWritingPrettyPrinted error:nil];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [jstools sendToLuaByWxCode:ret];
    [md release];
}

//非网络错误导致登录失败
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        NSLog(@"登录已被取消");
        NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
        [md setValue:@"qq_login" forKey:@"type"];
        [md setValue:@"-1" forKey:@"retCode"];
        [md setValue:@"-1" forKey:@"detailRetCode"];
        [md setValue:@"登录已被取消" forKey:@"message"];
        NSLog(@"%@", md);
        NSData *data = [NSJSONSerialization dataWithJSONObject:md options:NSJSONWritingPrettyPrinted error:nil];
        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [jstools sendToLuaByWxCode:ret];
        [md release];
    } else {
        NSLog(@"登录失败,请重新登录");
        NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
        [md setValue:@"qq_login" forKey:@"type"];
        [md setValue:@"-1" forKey:@"retCode"];
        [md setValue:@"-1" forKey:@"detailRetCode"];
        [md setValue:@"登录失败,请重新登录" forKey:@"message"];
        NSLog(@"%@", md);
        NSData *data = [NSJSONSerialization dataWithJSONObject:md options:NSJSONWritingPrettyPrinted error:nil];
        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [jstools sendToLuaByWxCode:ret];
        [md release];
    }
}
    
//网络错误导致登录失败
-(void)tencentDidNotNetWork
{
    NSLog(@"无网络连接，请设置网络");
    NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
    [md setValue:@"qq_login" forKey:@"type"];
    [md setValue:@"-1" forKey:@"retCode"];
    [md setValue:@"-1" forKey:@"detailRetCode"];
    [md setValue:@"无网络连接，请设置网络" forKey:@"message"];
    NSLog(@"%@", md);
    NSData *data = [NSJSONSerialization dataWithJSONObject:md options:NSJSONWritingPrettyPrinted error:nil];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [jstools sendToLuaByWxCode:ret];
    [md release];
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->pause(); */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->resume(); */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if(0 < [pasteboard.string length])
    {
        NSLog(@"app has enter foreground:%@", pasteboard.string);
        //[AppController setRoomId:[self isUrlType:pasteboard.string]];
        [AppController setRoomId:parseUrlFromStr(pasteboard.string)];
        pasteboard.string = @"";
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

-(void) onReq:(BaseReq*)req
{
    NSLog(@"onReq receive ball");
}

-(void) onResp:(BaseResp*)resp
{
    NSLog(@" get BaseResp...");
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strErrCode = [NSString stringWithFormat:@"%d", resp.errCode];
        NSLog(@"send message errcode: %@", strErrCode);
        NSMutableDictionary *data2;
        data2 = [[NSMutableDictionary alloc] init];
        [data2 setValue:@"weixin_message" forKey:@"type"];
        if(resp.errCode == 0){
            [data2 setValue:@"1" forKey:@"status"];
        }else{
            [data2 setValue:@"0" forKey:@"status"];
        }
        [data2 setValue:@"ok" forKey:@"code"];
        [jstools sendToLuaByWxCode:[data2 JSONString]];
        NSLog(@"%@",@"ok");
        [data2 release];
        
        
    }else if([resp isKindOfClass:[SendAuthResp class]])
    {
        
        NSMutableDictionary *data;
        data = [[NSMutableDictionary alloc] init];
        SendAuthResp *temp = (SendAuthResp*)resp;
        if (temp.code)
        {
            NSLog(@" wxlogin success %@",temp.code);
            
            [data setValue:@"weixin_token" forKey:@"type"];
            [data setValue:@"1" forKey:@"status"];
            [data setValue:temp.code forKey:@"code"];
            
            [jstools sendToLuaByWxCode:[data JSONString]];
            
        }else
        {
            NSString *errCode = [NSString stringWithFormat:@"%d", resp.errCode];
            
            NSLog(@" wxlogin error %@",errCode);
            [data setValue:@"weixin_token" forKey:@"type"];
            [data setValue:@"0" forKey:@"status"];
            [data setValue:@"-1" forKey:@"code"];
            
            [jstools sendToLuaByWxCode:[data JSONString]];
        }
        [data release];
        
    }else if([resp isKindOfClass:[PayResp class]]){
        NSLog(@"come");
        NSString * payErrCodestr = [NSString stringWithFormat:@"%d", resp.errCode];
        NSMutableDictionary *data1;
        data1 = [[NSMutableDictionary alloc] init];
        
        [data1 setValue:@"weixin_pay" forKey:@"type"];
        if(resp.errCode == 0){
            [data1 setValue:@"1" forKey:@"status"];
        }else{
            [data1 setValue:@"0" forKey:@"status"];
        }
        [data1 setValue:@"-1" forKey:@"code"];
        
        [jstools sendToLuaByWxCode:[data1 JSONString]];
        NSLog(@"%@",@"ok");
        [data1 release];
    }else if([resp isKindOfClass:[SendMessageToQQResp class]]) {
        NSLog(@"QQ share finished.");
        SendMessageToQQResp *msg = (SendMessageToQQResp *)resp;
        NSMutableDictionary *data2;
        data2 = [[NSMutableDictionary alloc] init];
        [data2 setValue:@"qq_share" forKey:@"type"];
        [data2 setValue:msg.result forKey:@"status"];
        [data2 setValue:@"ok" forKey:@"code"];
        [jstools sendToLuaByWxCode:[data2 JSONString]];
        NSLog(@"%@",@"ok");
        [data2 release];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"111----->%@", [url absoluteString]);
    return [WXApi handleOpenURL:url delegate:self];
    
    //UNDO
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"222----->%@", [url absoluteString]);
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"tencent%@", QQ_API_KEY]]) {
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
    }

    if ([url.absoluteString hasPrefix:@"ding"]) {
        return [DTOpenAPI handleOpenURL:url delegate:self];
    }
    
    if ([url.absoluteString hasPrefix:@"xianliao"]) {
        return [SugramApiManager handleOpenURL:url];
    }
    
    [AppController checkAppLink:url];
    
    return  YES;
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    NSLog(@"net changed......");
    Reachability * readh = [note object];
    if([readh isKindOfClass:[Reachability class]] ){
        NetworkStatus status = [readh currentReachabilityStatus];
        switch (status) {
            case NotReachable:
            {
                NSLog(@"not reachable");
                break;
            }
            default:
                break;
        }
    }
}

-(void) getPastContent
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSLog(@"content:%@",pasteboard.string);
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


#if __has_feature(objc_arc)
#else
- (void)dealloc {
    [window release];
    [_viewController release];
    [super dealloc];
}
#endif


@end
