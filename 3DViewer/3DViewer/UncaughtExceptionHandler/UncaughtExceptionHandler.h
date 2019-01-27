//
//  UncaughtExceptionHandler.h
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UncaughtExceptionHandler : NSObject<UIAlertViewDelegate>
{
    NSException* currentException;
}

@end

volatile void exceptionHandler(NSException *exception);

void InstallUncaughtExceptionHandler(void);
