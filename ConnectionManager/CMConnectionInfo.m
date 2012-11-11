//
//  CMConnectionInfo.m
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import "CMConnectionInfo.h"

@implementation CMConnectionInfo

- (id)init
{
    self = [super init];
    if(self){
        self.url = @"";
        self.maximumAllowableConnections = CMInfinte;
        self.queueType = QueueTypeNoQueuingCancel;
        self.HTTPType = HTTP_GET;
        self.postData = [NSMutableDictionary dictionary];
        self.completionBlock = ^(CustomConnection * connection){
            
        };
        self.newDataBlock = ^(CustomConnection * connection){
            
        };
        self.shouldShowActivityIndicator = TRUE;
        self.maximumNumberOfRetrys = CMInfinte;
        self.currentNumberOfRetrys = 0;
        self.object = nil;
    }
    
    return self;
}

@end
