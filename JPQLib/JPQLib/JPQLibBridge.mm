//
//  JPQLibCPlusPlusBridge.m
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#import "JPQLibBridge.h"
#import "JPQLib.h"

JPQLib* _jpqLib;

@implementation JPQLibBridge
- (instancetype)init
{
    self = [super init];
    if (self) {
        _jpqLib = new JPQLib();
    }
    return self;
}

@end
