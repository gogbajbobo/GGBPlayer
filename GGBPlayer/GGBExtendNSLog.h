//
//  GGBExtendNSLog.h
//  GGBPlayer
//
//  Created by Maxim Grigoriev on 08/01/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//


#import <Foundation/Foundation.h>


#define NSLogMethodName NSLog(@"%@", NSStringFromSelector(_cmd))


#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define NSLogM(callerInfo, args...) NSLogMessage(callerInfo, args);
#else
#define NSLog(x...)
#define NSLogM(x...)
#endif

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
void NSLogMessage(NSDictionary *callerInfo, NSString *format, ...);

