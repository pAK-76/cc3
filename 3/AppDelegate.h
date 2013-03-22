//
//  AppDelegate.h
//  3
//
//  Created by Pavel Aksenkin on 19.03.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Analyzer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    Grammar *_gr;
    Analyzer *_analyzer;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSTextView *grammarView;
@property (assign) IBOutlet NSTextField *chainField;

@end
