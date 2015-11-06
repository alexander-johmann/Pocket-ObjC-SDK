//
//  PocketAPIApplicationStateWatcher.m
//
//  Created by Alexander Smarus on 05.11.2015.
//
//  When app tries to open other app with openURL: on iOS 9
//  the system asks user to confirm the action.
//  And there is no proper way to detect when user cancels request.
//
//  This solution is based on specific sequence of application state transitions
//  which are only have place when iOS shows confiramtion
//  and then not opens requested app.
//
//  UIApplicationDidEnterBackgroundNotification means that we
//  successfully got switched to Pocket app.
//  UIApplicationDidBecomeActiveNotification means that
//  user have selected one of the options in confirmation alert.
//  We should expect UIApplicationDidEnterBackgroundNotification
//  in a moment as sign of success. No notification means failure.


#import "PocketAPIApplicationStateWatcher.h"

typedef NS_ENUM(NSUInteger, PocketAPIApplicationStateWatcherState) {
    PocketAPIApplicationStateWatcherStateInitial,
    PocketAPIApplicationStateWatcherStateSuccess,
    PocketAPIApplicationStateWatcherStateFailure
};

@interface PocketAPIApplicationStateWatcher ()

@property (nonatomic, assign) BOOL didEnterBackground;

@end


@implementation PocketAPIApplicationStateWatcher

- (void)expectBackgroundMode {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [self cancelScheduledFail];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.didEnterBackground = YES;
    [self cancelScheduledFail];
    [self reportSuccess];
}


- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!self.didEnterBackground) {
        [self reportFailAfterDelay];
    }
}

- (void)reportFailAfterDelay {
    [self performSelector:@selector(reportFail) withObject:nil afterDelay:0.3];
}

- (void)cancelScheduledFail {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reportFailAfterDelay) object:nil];
}

- (void)reportFail {
    [self.delegate applicationStateWatcher:self didDetectTransitionSuccess:NO];
}

- (void)reportSuccess {
    [self.delegate applicationStateWatcher:self didDetectTransitionSuccess:YES];
}

@end
