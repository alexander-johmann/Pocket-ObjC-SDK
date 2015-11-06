//
//  PocketAPIApplicationStateWatcher.h
//
//  Created by Alexander Smarus on 05.11.2015.
//

#import <Foundation/Foundation.h>

@class PocketAPIApplicationStateWatcher;

@protocol PocketAPIApplicationStateWatcherDelegate <NSObject>

- (void)applicationStateWatcher:(PocketAPIApplicationStateWatcher *)watcher didDetectTransitionSuccess:(BOOL)success;

@end

@interface PocketAPIApplicationStateWatcher : NSObject

@property (nonatomic, assign) id<PocketAPIApplicationStateWatcherDelegate> delegate;

- (void)expectBackgroundMode;

@end
