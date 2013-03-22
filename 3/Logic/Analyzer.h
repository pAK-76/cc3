//
//  Analyzer.h
//  3
//
//  Created by Pavel Aksenkin on 22.03.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import "Grammar.h"

typedef enum BottomReturningState {
    BottomReturningStateNorm    = 0,
    BottomReturningStateRet     = 1,
    BottomReturningStateFin     = 2
} BottomReturningState;
@interface Analyzer : NSObject
{
    Grammar *_grammar;
    NSMutableDictionary *_alternatives;
    BottomReturningState _state;
    NSUInteger _cur;
    NSMutableArray *_l1;
    NSMutableArray *_l2;
    NSArray *_tested;
}

-(void)reset;
-(BOOL)analyze:(NSString*)str withLogHandler:(void (^) (NSString* logString))logHandler;

@end
