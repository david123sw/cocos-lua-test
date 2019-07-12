//
//  yayavoice.m
//  MyJSGame
//
//  Created by jj043 on 16/8/7.
//
//

#import "yayavoice.h"
#import "YvIMCallBackBL.h"
#import "YvIMLoginBL.h"
#import "YvIMToolsBL.h"
#import "WXUtil.h"
#import "JSONKit.h"
#import "Utilities.h"
#import "jstools.h"

@implementation yayavoice
#define FMSep @"----WebKitFormBoundaryDYeXSvJz9Yuyf7Du"
#define FMNewLine @"\r\n"

static NSString* voiceProcessServerAddr = NULL;
+ (BOOL)voiceInit:(NSDictionary *)dict
{
//    NSLog(@"init%",ifDebug);
    NSString* appid = [dict objectForKey:@"appid"];
    BOOL ifDebug = [[dict objectForKey:@"ifDebug"] boolValue]; 
    [[YvIMCallBackBL shareInstance]initWithAppid:appid isTest:ifDebug];
    return true;

}
+ (BOOL)voiceLogin:(NSDictionary *)dict
{
    NSString* uid = [dict objectForKey:@"uid"];
    NSString* unick = [dict objectForKey:@"unick"];
    NSLog(@"login%@",uid);
    NSString * tt = [NSString stringWithFormat:@"{\"uid\": \"%@\", \"nickname\": \"%@\"}",uid,unick];
    NSArray * channelList = [NSArray arrayWithObjects:@"0x001",nil];
    [[YvIMLoginBL shareInstance]thirdLoginWithTT:tt pgameServiceID:@"1" channelList:channelList readstatus:1];
    return true;

}

+ (void) initVoiceRecordAndPlayProcessAddr:(NSDictionary *)dict {
    if (NULL == voiceProcessServerAddr)
    {
        voiceProcessServerAddr = [dict objectForKey:@"addr"];
        [voiceProcessServerAddr retain];
        NSLog(@"--------->initVoiceRecordAndPlayProcessAddr:%@", voiceProcessServerAddr);
    }
}

+ (BOOL)voiceuploadUpdated:(NSDictionary *)dict
{
    NSLog(@"--------->voiceuploadUpdated");
    NSString* path = [dict objectForKey:@"path"];
    NSString* time = [dict objectForKey:@"time"];
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    NSString* filePath = [path substringToIndex:range.location];
    NSString* fileName = [path substringFromIndex:range.location + 1];
    NSString* name = [WXUtil md5:[NSString stringWithFormat:@"%@%@", path, time]];
    NSString* newFileName = [NSString stringWithFormat:@"%@.amr", [name lowercaseString]];
    NSString* newFilePath = [NSString stringWithFormat:@"%@/%@", filePath, newFileName];
    /*
    NSLog(@"--------->filePath:%@", filePath);
    NSLog(@"--------->fileName:%@", fileName);
    NSLog(@"--------->newFileName:%@", newFileName);
    NSLog(@"--------->newFilePath:%@", newFilePath);
    NSLog(@"--------->voiceProcessServerAddr:%@", voiceProcessServerAddr);
    */
    NSError* err = NULL;
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL ret = [fm moveItemAtPath:path toPath:newFilePath error:&err];
    if(!ret) NSLog(@"Rename Error!");
    [fm release];

    NSString* urlString = [voiceProcessServerAddr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSString* fileDescription = @"game_voice";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@", FMSep];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [[NSMutableData data] retain];
    [body appendData:[[NSString stringWithFormat:@"--%@%@", FMSep, FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"%@%@", FMNewLine, FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@%@", fileDescription, FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@%@", FMSep, FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"%@%@", newFileName, FMNewLine, FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfFile:newFilePath]];
    [body appendData:[[NSString stringWithFormat:@"%@", FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--%@", FMSep, FMNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        int respCode = [response statusCode];
        NSLog(@"response code %d",respCode);
        if(200 == respCode) {
            NSMutableDictionary *dataRet = [[NSMutableDictionary alloc] init];
            NSString * backstr = [NSString stringWithFormat:@"%@/%@#%@", urlString, newFileName, time];
            NSString * errocode = [NSString stringWithFormat:@"%d", 1];
            [dataRet setValue:@"voice_url" forKey:@"type"];
            [dataRet setValue:errocode forKey:@"status"];
            [dataRet setValue:backstr forKey:@"code"];
            NSLog(@"url %@", backstr);
            NSLog(@"data->%@", dataRet);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataRet options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [jstools sendToLuaByWxCode:jsonString];
        }
        else{
            NSLog(@"error");
        }
    }];
    return true;
}

+ (BOOL)voiceupload:(NSDictionary *)dict
{
    return [yayavoice voiceuploadUpdated:dict];
    /*
    NSString* path = [dict objectForKey:@"path"];
    NSString* time = [dict objectForKey:@"time"];
    NSLog(@"record voiceupload");
    NSString * fid = [NSString stringWithFormat:@"%@",time];
    [[YvIMToolsBL shareInstance]uploadFileReq:path fileId:fid];
    return true;
    */
}
+ (BOOL)voiceStart
{
     NSLog(@"record start");
    NSString * strfile = [[YvIMToolsBL shareInstance] createRecordAudioFilePath];
    
    
    [[YvIMToolsBL shareInstance]startRecord:strfile ext:@"eppdk"];
    return true;


}
+ (BOOL)voiceStop
{
     NSLog(@"record stop");
    [[YvIMToolsBL shareInstance] stopRecord];
    return true;

}
+ (BOOL)voicePlay:(NSDictionary *)dict
{
    NSString* url = [dict objectForKey:@"url"];
    NSLog(@"record play%@",url);
    [[YvIMToolsBL shareInstance]playAudioWithUrl:url];
    return true;

}
+ (BOOL)yayaLoginOut
{
     [[YvIMLoginBL shareInstance]logout];
    return true;

}
+ (BOOL)voicePlayStop
{
    [[YvIMToolsBL shareInstance] stopPlayAudio];
    return true;
}
@end
