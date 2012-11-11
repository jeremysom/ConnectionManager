//
//  CMConnectionInfo.h
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CustomConnection;




// Allowable Connection Constants
#define CMInfinte -1

#define QueueTypeNoQueuingCancel 0          // Will cancel old connections and run the new one if it exceeds the maximumAllowableConnections
#define QueueTypeNoQueuingDontCancel 1      // Won't start the new connection if it exceeds the maximumAllowableConnections
#define QueueTypeQueuing 2                  // Queues the connections and will automatically start them when connections finish



// HTTP Constants
#define HTTP_GET @"GET"
#define HTTP_POST @"POST"


@interface CMConnectionInfo : NSObject

// URL
@property(nonatomic,strong)NSString * url;

// How many of these connections are allowed to be connecting at once
@property(nonatomic)NSInteger maximumAllowableConnections;

// Queuing allowed or not - default is QueueTypeNoQueuingCancel
@property(nonatomic)NSInteger queueType;

// POST/GET - Default is GET
@property(nonatomic)NSString * HTTPType;

// For Post Requests - the post data
@property(nonatomic,strong)NSMutableDictionary * postData;

// Is Called from connectionDidFinishLoading
@property(nonatomic,strong)void (^completionBlock)(CustomConnection *);

// Is Called from connectionDidGetData
@property(nonatomic,strong)void (^newDataBlock)(CustomConnection *);

// Should this connection affect the ActivityIndicator in the status bar - Default is YES
@property(nonatomic)BOOL shouldShowActivityIndicator;

// Maximum number of retrys the before it gives up
@property(nonatomic)NSInteger maximumNumberOfRetrys;
@property(nonatomic)NSInteger currentNumberOfRetrys;

// An object to provide any additional info about the connection
@property(nonatomic,strong)id object;







@end
