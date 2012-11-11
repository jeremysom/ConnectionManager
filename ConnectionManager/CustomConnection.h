//
//  CustomConnection.h
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ConnectionManagerDelegate;
@class CMConnectionInfo;


// Create Typedef for ConnectionType
typedef NSString * ConnectionType;



// Default Connection Types
#define kConnectionTypeNone @"None"



@interface CustomConnection : NSURLConnection

@property(nonatomic)ConnectionType connectionType;
@property(nonatomic,strong)NSMutableData * data;
@property(nonatomic,weak)id <ConnectionManagerDelegate> myDelegate;
@property(nonatomic,strong)CMConnectionInfo * connectionInfo;



@end
