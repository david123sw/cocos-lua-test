//
//  wxlogin.m
//  Baccarat
//
//  Created by jj043 on 15/9/17.
//
//

#import "wxlogin.h"
#import "payRequsestHandler.h"
#import "NSDataEx.h"
#import "WXApi.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface wxlogin()
{
}
@end

@implementation wxlogin

+ (int)isWechatInstalled
{
    BOOL r = [WXApi isWXAppInstalled];
    if (r) {
        NSLog(@"ifwechat installed yes");
        return 1;
    }
    else {
        NSLog(@"ifwechat installed no");
        return 0;
    }
}


+ (BOOL)sendAuthReqForLoginWX:(NSDictionary *)dict
{
    NSString *wxid = [dict objectForKey:@"wxid"];
    [WXApi registerApp:wxid enableMTA:YES];

    NSLog(@"sendAuthReqForLoginWx %@",wxid);
    SendAuthReq *request = [[[SendAuthReq alloc] init]autorelease];
    request.scope = @"snsapi_userinfo";
    request.state = @"klds2";
    
    [WXApi sendReq:request];
    return  YES;//true;
}



+ (BOOL)wxPay:(NSDictionary *)dict
{
    NSLog(@"url:%@",dict);
    if(dict != nil){
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = [[dict objectForKey:@"timestamp"] unsignedIntValue];//stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        [WXApi sendReq:req];
        //NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign);
        return YES;
    }else{
        return NO;
    }
    /*
    NSString *prePayid = [dictParam objectForKey:@"prePayid"];
    NSString *wxid = [dictParam objectForKey:@"wxid"];
    NSString *mchid = [dictParam objectForKey:@"mchid"];
    [WXApi registerApp:wxid enableMTA:YES];
    NSLog(@"wxpay%@",prePayid);
    NSLog(@"wxid%@",wxid);
    NSLog(@"mchid%@",mchid);
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] autorelease];
    //初始化支付签名对象
    [req init:wxid mch_id:mchid];
    //设置密钥
    [req setKey:PARTNER_ID];
    NSMutableDictionary *dict = [req sendPay_demo:prePayid];
    
    
    
    if(dict== nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
        //            [self alert:@"提示信息" msg:debug];
        
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        //[self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[[PayReq alloc] init]autorelease];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
    */
    return YES;
}

+ (BOOL)sendMessage:(NSString *)strShareTo
                 str:(NSString *)str
{
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.text = str;
    req.bText = YES;
    
    if ([strShareTo  isEqual: @"WXSceneFavorite"])
    {
        req.scene = WXSceneFavorite;
    }
    else if([strShareTo isEqualToString:@"WXSceneTimeline"])
    {
        req.scene = WXSceneTimeline;
    }else
        req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
    return true;
}

+ (BOOL)sendAppContent:(NSString *)strShareTo
                 title:(NSString *)strTitle
                  text:(NSString *)strText
                   url:(NSString *)url
                 image:(UIImage *)uiImage
{
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = strTitle;
    message.description = strText;
    [message setThumbImage:uiImage];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"<xml>extend info</xml>";
    ext.url = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    if ([strShareTo  isEqual: @"WXSceneFavorite"])
    {
        req.scene = WXSceneFavorite;
    }
    else if([strShareTo isEqualToString:@"WXSceneTimeline"])
    {
        req.scene = WXSceneTimeline;
    }else
        req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
    return true;
}

+ (BOOL)sendLinkContent:(NSDictionary *)dict
{
    NSString *strShareTo = [dict objectForKey:@"shareTo"];
    NSString *strTitle = [dict objectForKey:@"title"];
    NSString *strText = [dict objectForKey:@"text"];
    NSString *url = [dict objectForKey:@"url"];
    
    if([strTitle isEqualToString:@""] && [url isEqualToString:@""]) {
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.text = strText;
        req.bText = YES;
        if ([strShareTo  isEqual: @"WXSceneFavorite"])
        {
            req.scene = WXSceneFavorite;
        }
        else if([strShareTo isEqualToString:@"WXSceneTimeline"])
        {
            req.scene = WXSceneTimeline;
        }else
            req.scene = WXSceneSession;
        
        [WXApi sendReq:req];
        return true;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = strTitle;
    message.description = strText;
//    NSDictionary *infoPlist = [[NSBundle mainBundle]infoDictionary];
    
//    NSString * icon =[[infoPlist valueForKey:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles" ] lastObject];
//    NSLog(@"icon.....");
//    NSLog(icon);
    UIImage* uiImagephoto = [UIImage imageNamed:@"Icon-114.png"];

    [message setThumbImage:[self thumbnailOfImage:uiImagephoto withMaxSize:100]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    if ([strShareTo  isEqual: @"WXSceneFavorite"])
    {
        req.scene = WXSceneFavorite;
    }
    else if([strShareTo isEqualToString:@"WXSceneTimeline"])
    {
        req.scene = WXSceneTimeline;
    }else
        req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
     return true;
}

+ (BOOL)sendImageContent:(NSDictionary *)dict
{
    NSString *strShareTo = [dict objectForKey:@"shareTo"];
    NSLog(@"%@\n\n",strShareTo);
    NSString *strFilePath = [dict objectForKey:@"filePath"];
    NSLog(@"%@\n\n",strFilePath);
    UIImage* uiImagephoto = [UIImage imageWithContentsOfFile:strFilePath];//[self getImgaeByphone];

    WXMediaMessage *message = [WXMediaMessage message];
    UIImage *thumb = [self thumbnailOfImage:uiImagephoto withMaxSize:100];
    [message setThumbImage:thumb];
    
    WXImageObject *ext = [WXImageObject object];    
    ext.imageData = UIImageJPEGRepresentation(uiImagephoto, 0.8);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    if ([strShareTo  isEqual: @"WXSceneFavorite"])
    {
        req.scene = WXSceneFavorite;
    }
    else if([strShareTo isEqualToString:@"WXSceneTimeline"])
    {
        req.scene = WXSceneTimeline;
    }else
        req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
    return true;
}

+ (UIImage*) getImgaeByphone
{
    
    BOOL ignoreOrientation = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGSize imageSize = CGSizeZero;
    if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation)
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        // Correct for the screen orientation
        if(!ignoreOrientation)
        {
            if(orientation == UIInterfaceOrientationLandscapeLeft)
            {
                CGContextRotateCTM(context, (CGFloat)M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            }
            else if(orientation == UIInterfaceOrientationLandscapeRight)
            {
                CGContextRotateCTM(context, (CGFloat)-M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            }
            else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                CGContextRotateCTM(context, (CGFloat)M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
        }
        
        if([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        else
            [window.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage*)thumbnailOfImage:(UIImage*)image withMaxSize:(float)maxsize
{
    //NSLog(@"create thumbnail image");
    
    if (!image)
        return nil;
    
    CGImageRef imageRef = [image CGImage];
    UIImage *thumb = nil;
    
    float _width = CGImageGetWidth(imageRef);
    float _height = CGImageGetHeight(imageRef);
    
    // hardcode width and height for now, shouldn't stay like that
    float _resizeToWidth;
    float _resizeToHeight;
    
    if (_width > _height){
        _resizeToWidth = maxsize;
        _resizeToHeight = maxsize * _height / _width;
    }else{
        _resizeToHeight = maxsize;
        _resizeToWidth = maxsize * _width / _height;
    }
    
    //    _resizeToWidth = aSize.width;
    //    _resizeToHeight = aSize.height;
    
    float _moveX = 0.0f;
    float _moveY = 0.0f;
    
    // determine the start position in the window if it doesn't fit the sizes 100%
    
    //NSLog(@" width: %f  to: %f", _width, _resizeToWidth);
    //NSLog(@" height: %f  to: %f", _height, _resizeToHeight);
    
    // resize the image if it is bigger than the screen only
    if ( (_width > _resizeToWidth) || (_height > _resizeToHeight) )
    {
        float _amount = 0.0f;
        
        if (_width > _resizeToWidth)
        {
            _amount = _resizeToWidth / _width;
            _width *= _amount;
            _height *= _amount;
            
            //NSLog(@"1 width: %f height: %f", _width, _height);
        }
        
        if (_height > _resizeToHeight)
        {
            _amount = _resizeToHeight / _height;
            _width *= _amount;
            _height *= _amount;
            
            //NSLog(@"2 width: %f height: %f", _width, _height);
        }
    }
    
    _width = (NSInteger)_width;
    _height = (NSInteger)_height;
    
    _resizeToWidth = _width;
    _resizeToHeight = _height;
    
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                _resizeToWidth,
                                                _resizeToHeight,
                                                CGImageGetBitsPerComponent(imageRef),
                                                CGImageGetBitsPerPixel(imageRef)*_resizeToWidth,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef)
                                                );
    
    // now center the image
    _moveX = (_resizeToWidth - _width) / 2;
    _moveY = (_resizeToHeight - _height) / 2;
    
    CGContextSetRGBFillColor(bitmap, 1.f, 1.f, 1.f, 1.0f);
    CGContextFillRect( bitmap, CGRectMake(0, 0, _resizeToWidth, _resizeToHeight));
    CGContextDrawImage( bitmap, CGRectMake(_moveX, _moveY, _width, _height), imageRef );
    
    // create a templete imageref.
    CGImageRef ref = CGBitmapContextCreateImage( bitmap );
    thumb = [UIImage imageWithCGImage:ref];
    
    // release the templete imageref.
    CGContextRelease( bitmap );
    CGImageRelease( ref );
    
    return [[thumb retain] autorelease];
}
@end
