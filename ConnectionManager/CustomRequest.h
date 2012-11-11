//
//  CustomRequest.h
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomRequest : NSMutableURLRequest

-(void)addInfo:(NSDictionary *)userInfo;

@end
