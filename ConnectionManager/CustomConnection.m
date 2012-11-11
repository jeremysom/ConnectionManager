//
//  CustomConnection.m
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import "CustomConnection.h"

@implementation CustomConnection

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    self = [super initWithRequest:request delegate:delegate startImmediately:NO];
    
    if(self){
        self.data = [NSMutableData dataWithLength:0];
        self.connectionType = kConnectionTypeNone;
    }
    
    return self;
}

@end
