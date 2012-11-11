//
//  CustomRequest.m
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import "CustomRequest.h"
#import "CustomConnection.h"

@implementation CustomRequest

- (void)addInfo:(NSDictionary *)userInfo
{
    // Add Options
    NSString * prefix = @"";
    NSString *optionsString = @"";
    
    for(NSString * key in userInfo){
        optionsString = [NSString stringWithFormat:@"%@%@%@=%@",optionsString, prefix, key, [userInfo objectForKey:key]];
        prefix = @"&";
    }
    
    [self setHTTPBody:[[optionsString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
}

@end
