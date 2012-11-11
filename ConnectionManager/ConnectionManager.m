//
//  ConnectionManager.m
//  ConnectionManager
//
//  Created by Jeremy Somerville on 10/11/12.
//  Copyright (c) 2012 Jeremy Somerville. All rights reserved.
//

#import "ConnectionManager.h"
#import <UIKit/UIKit.h>

#define StringsEqual(a,b) [a isEqualToString:b]

#define defaultTestHost @"google.com"

// Private Functions
@interface ConnectionManager ()

- (void)initialise;

- (void)retryConnection:(CustomConnection *)connection;


@end





@implementation ConnectionManager




// Returns a singleton manager
- (id)init
{
    self = [super init];
    if(self){
        [self initialise];
        
    }
    return self;
}

+ (id)sharedManager
{
    static ConnectionManager * sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        //[sharedManager initialise];
    });
    
    return sharedManager;
}

- (void)initialise
{
    self.aryCurrentConnections = [NSMutableArray array];
    self.aryQueuedConnections = [NSMutableArray array];
    
    self.shouldAllowWWANConnections = YES;
    self.isInternetReachable = NO;
    
    
    // Start Notifcations for internet connectivity
    
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    self.reach.reachableOnWWAN = self.shouldAllowWWANConnections;
    
    __weak ConnectionManager * connectionManager = self;
    self.reach.reachableBlock = ^(Reachability * reachability){
        dispatch_async(dispatch_get_main_queue(), ^{
            [connectionManager notifyDelegateOfReachabilityChange:TRUE];
        });
    };
    
    self.reach.unreachableBlock = ^(Reachability * reachability){
        dispatch_async(dispatch_get_main_queue(), ^{
            [connectionManager notifyDelegateOfReachabilityChange:FALSE];
        });
    };
    
    [self.reach startNotifier];
}





// Reachability
- (void)notifyDelegateOfReachabilityChange:(BOOL)reachable
{
    self.isInternetReachable = reachable;
    if([self.delegate respondsToSelector:@selector(reachabilityDidChange:)]){
        [self.delegate reachabilityDidChange:reachable];
    }
}
- (void)setShouldAllowWWANConnections:(BOOL)shouldAllowWWANConnections
{
    _shouldAllowWWANConnections = shouldAllowWWANConnections;
    [self.reach stopNotifier];
    self.reach.reachableOnWWAN = shouldAllowWWANConnections;
    [self.reach startNotifier];
}






// Queue Handling
- (void)checkQueue
{
    if(self.aryCurrentConnections.count == 0){
        UIApplication * app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
        
        // Send Delegate the notification
        if([self.delegate respondsToSelector:@selector(allConnectionsDidFinish)]){
            [self.delegate allConnectionsDidFinish];
        }
    }
}

- (NSInteger)numberOfConnectionsWithType:(ConnectionType)connectionType includeQueued:(BOOL)includeQueued
{
    int count = 0;
    for(CustomConnection * connection in self.aryCurrentConnections){
        count++;
    }
    
    if(includeQueued){
        for(CustomConnection * connection in self.aryQueuedConnections){
            count++;
        }
    }
    
    return count;
}

- (void)cancelConnectionsOfType:(ConnectionType)connectionType
{
    int counter = 0;
    while(counter < self.aryCurrentConnections.count){
        CustomConnection * connection = self.aryCurrentConnections[counter];
        if(connection.connectionType == connectionType){
            [connection cancel];
            [self.aryCurrentConnections removeObjectAtIndex:counter];
            counter--;
        }
        counter++;
    }
    
    counter = 0;
    while(counter < self.aryQueuedConnections.count){
        CustomConnection * connection = self.aryQueuedConnections[counter];
        if(connection.connectionType == connectionType){
            [self.aryQueuedConnections removeObjectAtIndex:counter];
            counter--;
        }
        counter++;
    }
    
}










// Start Connections

- (void)beginConnectionOfType:(ConnectionType)connectionType delegate:(id <ConnectionManagerDelegate>)delegate withObject:(id)object
{

    CMConnectionInfo * connectionInfo = [delegate connectionInfoForConnectionType:connectionType object:object];
    if(!connectionInfo){
        connectionInfo = [[CMConnectionInfo alloc] init];
    }
    
    
    
    
    // Create the Request
    CustomRequest * request = [[CustomRequest alloc] init];
    
    // HTTP Type
    if([connectionInfo.HTTPType isEqualToString:HTTP_GET]){
        [request setHTTPMethod:@"GET"];
    }else if([connectionInfo.HTTPType isEqualToString:HTTP_POST]){
        [request setHTTPMethod:@"POST"];
    }
    
    
    // URL
    request.URL = [NSURL URLWithString:connectionInfo.url];
    
    // Post Data
    [request addInfo:connectionInfo.postData];
    
    
    
    // Create Request
    
    CustomConnection * connection = [[CustomConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    // Connection Type
    connection.connectionType = connectionType;
    connection.myDelegate = delegate;
    connection.connectionInfo = connectionInfo;
    
    
    
    if([self numberOfConnectionsWithType:connectionType includeQueued:YES] >= connectionInfo.maximumAllowableConnections){
        if(connectionInfo.queueType == QueueTypeNoQueuingCancel)
        {
            // Start the Connection after cancelling any others
            [self cancelConnectionsOfType:connectionType];
        }
        else if(connectionInfo.queueType == QueueTypeNoQueuingDontCancel)
        {
            // Don't allow the connection to start
            return;
        }
        else if(connectionInfo.queueType == QueueTypeNoQueuingDontCancel)
        {
            // Add connection to the queue
            [self.aryQueuedConnections addObject:connection];
            return;
        }
    }
    
    
    
    [self.aryCurrentConnections addObject:connection];
    
    [connection start];
    
}

- (void)retryConnection:(CustomConnection *)retryConnection
{
    // Create the Request
    CustomRequest * request = (CustomRequest *)retryConnection.originalRequest;

    // Create Connection
    
    CustomConnection * connection = [[CustomConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    // Connection Type
    connection.connectionType = retryConnection.connectionType;
    connection.myDelegate = retryConnection.myDelegate;
    connection.connectionInfo = retryConnection.connectionInfo;
    
    
    if([self numberOfConnectionsWithType:retryConnection.connectionType includeQueued:YES] >= retryConnection.connectionInfo.maximumAllowableConnections){
        if(retryConnection.connectionInfo.queueType == QueueTypeNoQueuingCancel)
        {
            // Start the Connection after cancelling any others
            [self cancelConnectionsOfType:retryConnection.connectionType];
        }
        else if(retryConnection.connectionInfo.queueType == QueueTypeNoQueuingDontCancel)
        {
            // Don't allow the connection to start
            return;
        }
        else if(retryConnection.connectionInfo.queueType == QueueTypeNoQueuingDontCancel)
        {
            // Add connection to the queue
            [self.aryQueuedConnections addObject:connection];
            return;
        }
    }
    
    
    
    [self.aryCurrentConnections addObject:connection];
    
    [connection start];
}





// Connections

- (void)connection:(CustomConnection *)connection didReceiveData:(NSData *)data
{
    [connection.data appendData:data];
    if(connection.connectionInfo.shouldShowActivityIndicator){
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
    }
    
    connection.connectionInfo.newDataBlock(connection);
    
    
    // Send Delegate the notification
    if([connection.myDelegate respondsToSelector:@selector(connectionDidGetData:)]){
        [connection.myDelegate connectionDidGetData:connection];
    }
}

- (void)connectionDidFinishLoading:(CustomConnection *)connection
{
    [self.aryCurrentConnections removeObject:connection];
    [self checkQueue];
    
    connection.connectionInfo.completionBlock(connection);
    
    // Send Delegate the notification
    if([connection.myDelegate respondsToSelector:@selector(connectionDidFinish:)]){
        [connection.myDelegate connectionDidFinish:connection];
    }
}

- (void)connection:(CustomConnection *)connection didFailWithError:(NSError *)error
{
    [self.aryCurrentConnections removeObject:connection];
    [self checkQueue];
    
    if(connection.connectionInfo.maximumNumberOfRetrys > connection.connectionInfo.currentNumberOfRetrys){
        [self retryConnection:connection];
    }
}





// File Operations
- (NSString *)documentsPath
{
    NSArray * documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}

- (BOOL)fileExists:(NSString *)fileName
{
    NSString * thePath = [[self documentsPath] stringByAppendingPathComponent:@"filename"];
    return [[NSFileManager defaultManager] fileExistsAtPath:thePath];
}




// Other Helpers
- (NSString *)stringFromData:(NSData *)data
{
    NSString * strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(strData.length == 0){
        strData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    return strData;
}

- (NSDictionary *)JSONFromData:(NSData *)data
{
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
