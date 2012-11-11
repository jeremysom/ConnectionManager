//
//  ConnectionManager.h
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomRequest.h"
#import "CustomConnection.h"
#import "CMConnectionInfo.h"

#import "Reachability.h"










// Protocol Methods
@protocol ConnectionManagerDelegate <NSObject>

@required
// Handle Connection of type
- (CMConnectionInfo *)connectionInfoForConnectionType:(ConnectionType)connectionType object:(id)object;

@optional

// Connection Handling if needed
- (void)connectionDidGetData:(CustomConnection *)connection;// Called after the newDataBlock

- (void)connectionDidFinish:(CustomConnection *)connection; // Called after the completionBlock

- (void)reachabilityDidChange:(BOOL)reachable;

- (void)allConnectionsDidFinish;

@end








@interface ConnectionManager : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

// Arrays of Connections
@property(nonatomic,strong)NSMutableArray * aryCurrentConnections;
@property(nonatomic,strong)NSMutableArray * aryQueuedConnections;

// Internet Connectivity
@property(nonatomic)BOOL shouldAllowWWANConnections; // Default is yes.
@property(nonatomic)BOOL isInternetReachable;
   
@property(nonatomic,strong)Reachability * reach;

// Delegate
@property(nonatomic,weak)id <ConnectionManagerDelegate> delegate;




//////////////// Public Methods ////////////////



// Returns a singleton manager
+ (id)sharedManager;



// Queue Handling
- (void)checkQueue;

- (NSInteger)numberOfConnectionsWithType:(ConnectionType)connectionType includeQueued:(BOOL)includeQueued;

- (void)cancelConnectionsOfType:(ConnectionType)connectionType;




// Start Connections
- (void)beginConnectionOfType:(ConnectionType)connectionType delegate:(id <ConnectionManagerDelegate>)delegate  withObject:(id)object;




// File Operations
- (NSString *)documentsPath;
- (BOOL)fileExists:(NSString *)fileName;


// Other Helpers
- (NSString *)stringFromData:(NSData *)data;
- (NSDictionary *)JSONFromData:(NSData *)data;

@end
