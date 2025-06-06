/**
 * Tencent is pleased to support the open source community by making MLeaksFinder available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import "MLeaksMessenger.h"
#import <objc/runtime.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
static __weak UIAlertView *alertView;
#else
static __weak UIAlertView *alertView;
#endif

@implementation MLeaksMessenger

+ (void)setShowAlert:(BOOL)showAlert {
    objc_setAssociatedObject(self, @"showAlert", @(showAlert), OBJC_ASSOCIATION_ASSIGN);
}

+ (BOOL)showAlert {
    return [objc_getAssociatedObject(self, @"showAlert") boolValue];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message delegate:nil additionalButtonTitle:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              delegate:(id<UIAlertViewDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle {
    if ([self showAlert]) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        if (@available(iOS 9, *)) {
            UIAlertController * alertViewTemp = [UIAlertController
                                                 alertControllerWithTitle:title
                                                 message:message
                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                //do something when click button
            }];
            [alertViewTemp addAction:okAction];
            [[self getCurrentVC] presentViewController:alertViewTemp animated:YES completion:nil];
        }
        else{
            UIAlertView *alertViewTemp = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:delegate
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:additionalButtonTitle, nil];
            [alertViewTemp show];
            alertView = alertViewTemp;
        }
    }
    NSLog(@"MLeaksFinder: %@: %@", title, message);
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC {
   ///下文中有分析
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }

    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}


@end
