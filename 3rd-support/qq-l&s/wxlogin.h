//
//  wxlogin.h
//  Baccarat
//
//  Created by jj043 on 15/9/17.
//
//

#import <Foundation/Foundation.h>




@interface wxlogin : NSObject

NS_ASSUME_NONNULL_BEGIN
+ (int)isWechatInstalled;
+ (BOOL)sendAuthReqForLoginWX:(NSDictionary *)dict;
+ (BOOL)wxPay:(NSDictionary *)dict;
+ (BOOL)sendMessage:(NSString *)strShareTo
                str:(NSString *)str;
+ (BOOL)sendAppContent:(NSString *)shareTo
                      title:(NSString *)title
                       text:(NSString *)text
                        url:(NSString *)url
                      image:(UIImage *)image;
+ (BOOL)sendLinkContent:(NSDictionary *)dict;
+ (BOOL)sendImageContent:(NSDictionary *)dict;
+ (UIImage*)thumbnailOfImage:(UIImage*)image withMaxSize:(float)maxsize;
NS_ASSUME_NONNULL_END
@end


