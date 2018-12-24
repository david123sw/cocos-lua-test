/****************************************************************************
 Copyright (c) 2013      cocos2d-x.org
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

#import "RootViewController.h"
#import "cocos2d.h"
#import "platform/ios/CCEAGLView-ios.h"
#import <DTShareKit/DTOpenKit.h>
#import "XianliaoSDK_iOS/SugramApiManager.h"
#import "AppController.h"
#import <AVFoundation/AVFoundation.h>

#import <sys/utsname.h>
@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    // Initialize the CCEAGLView
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [UIScreen mainScreen].bounds
                                         pixelFormat: (__bridge NSString *)cocos2d::GLViewImpl::_pixelFormat
                                         depthFormat: cocos2d::GLViewImpl::_depthFormat
                                  preserveBackbuffer: NO
                                          sharegroup: nil
                                       multiSampling: NO
                                     numberOfSamples: 0 ];
    
    // Enable or disable multiple touches
    [eaglView setMultipleTouchEnabled:NO];
    
    // Set EAGLView as view of RootViewController
    self.view = eaglView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"isDingTalkInstalled: %@", @([DTOpenAPI isDingTalkInstalled]));
    NSLog(@"isDingTalkSupportOpenAPI: %@", @([DTOpenAPI isDingTalkSupportOpenAPI]));
    NSLog(@"appStoreURLOfDingTalk: %@", [DTOpenAPI appStoreURLOfDingTalk]);
    NSLog(@"openAPIVersion: %@", [DTOpenAPI openAPIVersion]);
    
    [SugramApiManager showLog:true];
    [SugramApiManager getGameFromSugram:^(NSString *roomToken, NSString *roomId, NSNumber *openId) {
        NSString *gameString = [NSString stringWithFormat:@"roomToken:%@, roomId:%@, openId:%@", roomToken, roomId, openId];
        NSLog(@"XL->%@", gameString);
        if(NULL != roomId)
        {
            NSURL *url = [NSURL URLWithString:roomId];
            [AppController checkAppLink:url];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}
    
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
}


// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
#ifdef __IPHONE_6_0
- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
#endif

- (BOOL) shouldAutorotate {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    auto glview = cocos2d::Director::getInstance()->getOpenGLView();

    if (glview)
    {
        CCEAGLView *eaglview = (__bridge CCEAGLView *)glview->getEAGLView();

        if (eaglview)
        {
            CGSize s = CGSizeMake([eaglview getWidth], [eaglview getHeight]);
            cocos2d::Application::getInstance()->applicationScreenSizeChanged((int) s.width, (int) s.height);
        }
    }
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

-(UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeBottom;
}

-(BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

bool changeViewFrame = false;
- (void)updateOrientation {
    if (@available(iOS 11.0, *)) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        if (self.view and !changeViewFrame)
        {
            NSLog(@"width:%f", width);
            NSLog(@"height:%f", height);
            NSLog(@"scale_screen:%f", scale_screen);
            NSLog(@"-self.view.frame.size.width:%f", self.view.frame.size.width);
            NSLog(@"-self.view.frame.size.width:%f", self.view.frame.size.height);
            NSLog(@"-self.view.safeAreaInsets-:%f", self.view.safeAreaInsets.left);
            NSLog(@"-self.view.safeAreaInsets-:%f", self.view.safeAreaInsets.right);
            NSLog(@"-self.view.safeAreaInsets-:%f", self.view.safeAreaInsets.bottom);
            NSLog(@"-self.view.safeAreaInsets-:%f", self.view.safeAreaInsets.top);
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString *pf = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            NSLog(@"pf:%@", pf);
            if([pf containsString:@"iPhone10"] || [pf containsString:@"x86_64"]) {
                int frameSizeWidth = self.view.frame.size.width;
                int frameSizeHeight = self.view.frame.size.height;
                CGRect s = CGRectMake(self.view.safeAreaInsets.left + 44,0,frameSizeWidth - 44,frameSizeHeight);
                self.view.frame = s;
            }
        }
    } else {
        //nothing
    }
}

-(void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    NSLog(@"viewSafeAreaInsetsDidChange %@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    [self updateOrientation];
    if( 0 == self.view.safeAreaInsets.left && 0 == self.view.safeAreaInsets.top && 21 == self.view.safeAreaInsets.bottom && 44 == self.view.safeAreaInsets.right)
    {
        changeViewFrame = true;
    }
}
@end
