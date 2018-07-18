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

#import <CoreLocation/CoreLocation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#include "scripting/lua-bindings/manual/CCLuaEngine.h"

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
        pasteboard.string = @"";//mod
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
    if(NULL != text) {
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
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
        NSLog(@"QQApiSendResultCode %d", sent);
        if(0 != sent) {
            NSString *strErrCode = [NSString stringWithFormat:@"%d", sent];
            NSLog(@"send message errcode: %@", strErrCode);
            NSMutableDictionary *data2;
            data2 = [[NSMutableDictionary alloc] init];
            [data2 setValue:@"qq_share" forKey:@"type"];
            [data2 setValue:[NSString stringWithFormat:@"%d", sent] forKey:@"status"];
            [data2 setValue:@"not-ok" forKey:@"code"];
            [jstools sendToLuaByWxCode:[data2 JSONString]];
            NSLog(@"%@",@"ok");
            [data2 release];
        }
    }
}

+(void) requestQQLogin {
    cocos2d::Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("qq_login");
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
    /*[self configLocationManager];*/
     
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
        [_tencentOauth accessToken] ;
        [_tencentOauth openId] ;
        [_tencentOauth expirationDate];
    });
    cocos2d::Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(listener, -1);
     
    return YES;
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
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [WXApi handleOpenURL:url delegate:self];

    if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"tencent%@", QQ_API_KEY]]) {
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
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
