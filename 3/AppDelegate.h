//
//  AppDelegate.h
//  3
//
//  Created by Pavel Aksenkin on 19.03.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GrammarController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet GrammarController *grController;

@end
