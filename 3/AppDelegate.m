//
//  AppDelegate.m
//  3
//
//  Created by Pavel Aksenkin on 19.03.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

-(void)awakeFromNib
{
    _gr = [Grammar instance];
    [_gr removeLeftRecursy];
    [_grammarView setEditable:NO];
    [_grammarView setSelectable:YES];
    [_grammarView setString:_gr.description];
    
    _analyzer = [[Analyzer alloc] init];
}

-(IBAction)analyze:(id)sender
{
    NSString *chain = [_chainField stringValue];
    [_logView setString:@""];

    if ([_analyzer analyze:chain withLogHandler:^(NSString *logString) {
        [self backLog:logString];
//        [self performSelectorInBackground:@selector(backLog:) withObject:logString];
    }]) {
        [self backLog:@"Допустимое выражение"];
    } else {
        [self backLog:@"Недопустимое выражение"];
    }
}

-(void)backLog:(NSString*)logString
{
//    NSLog(@"%@", logString);
    [_logView setString:[NSString stringWithFormat:@"%@\n%@", _logView.string, logString]];
}

@end
