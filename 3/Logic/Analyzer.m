//
//  Analyzer.m
//  3
//
//  Created by Pavel Aksenkin on 22.03.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import "Analyzer.h"

@implementation Analyzer

-(id)init
{
    self = [super init];
    if (self) {
        _grammar = [Grammar instance];
        _alternatives = [NSMutableDictionary dictionary];
        for (NSString *nterm in _grammar.nterms) {
            [_alternatives setObject:[_grammar alternativesFor:nterm] forKey:nterm];
        }
        _l1 = [NSMutableArray array];
        _l2 = [NSMutableArray array];
        [self reset];
    }
    return self;
}

-(void)reset
{
    _cur = 0;
    _state = BottomReturningStateNorm;
    [_l1 removeAllObjects];
    [_l2 removeAllObjects];
    [_l2 addObject:_grammar.axiom];
}

-(BOOL)analyze:(NSString *)str withLogHandler:(void (^)(NSString *))logHandler
{
    [self reset];
    NSError *error;
    _tested = [self symbolsFromRawString:str error:&error];
    if (error) {
        logHandler(error.description);
        return NO;
    }
    BOOL isAllowed = YES;
    BOOL isFinished = NO;
    while(!isFinished) {
        // Do something
        logHandler([self description]);
        switch (_state) {
                
            case BottomReturningStateNorm:
            {
                if (_l2.count == 0) {
                    if (_cur == _tested.count) {
                        [self successfulFinish];
                    } else {
                        [self failedComparison];
                    }
                } else {
                    NSString *sym = _l2[0];
                    if ([_grammar.terms containsObject:sym]) {
                        if (_cur < _tested.count && [_tested[_cur] isEqualTo:sym]) {
                            [self successfulComparison];
                        } else {
                            [self failedComparison];
                        }
                    } else if ([_grammar.nterms containsObject:sym]) {
                        [self treeGrowth];
                    } else {
                        NSLog(@"WHAT IS IT IF NOT TERM AND NOT NTERM???");
                    }
                }
                break;
            }
            case BottomReturningStateRet:
            {
                id sym = [_l1 lastObject];
                if ([sym isKindOfClass:[NSString class]]) {
                    [self enterRet];
                } else if ([sym isKindOfClass:[NSArray class]]) {
                    if ([self yetAnotherChallenge]) {
                        isFinished = YES;
                        isAllowed = NO;
                    }
                } else {
                    NSLog(@"WHAT IS IT IF NOT TERM AND NOT NTERM???");
                }
                break;
            }
                
            case BottomReturningStateFin:
                isFinished = YES;
                break;
                
            default:
                break;
        }
    }
    
    return isAllowed;
}
-(NSString *)description
{
    NSMutableString *l1Descr = [NSMutableString string];
    for (id i in _l1) {
        if ([i isKindOfClass:[NSString class]]) {
            [l1Descr appendString:i];
        } else {
            [l1Descr appendString:[NSString stringWithFormat:@"[%@,%@]", ((NSArray*)i)[0], ((NSArray*)i)[1]]];
        }
    }
    NSString *stateDescr = (_state == BottomReturningStateNorm) ? @"q" : (_state == BottomReturningStateRet) ? @"b" : @"t";
    return [NSString stringWithFormat:@"( %@, %lu, %@, %@ )", stateDescr, _cur, l1Descr, [_l2 componentsJoinedByString:@""]];
}

#pragma mark PrimitiveLexicalAnalysis
-(NSArray*)symbolsFromRawString:(NSString*)str error:(NSError**)error;
{
    NSMutableArray *result = [NSMutableArray array];
    NSUInteger i=0, j=0;
    while(i < str.length) {
        if (i + ++j > str.length) {
            *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"Неизвестная последовательность символов: '%@'", [[str substringWithRange:NSMakeRange(i, j-i-1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] code:0 userInfo:nil];
            return nil;
        }
        NSString *curSymbol = [[str substringWithRange:NSMakeRange(i, j)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([_grammar.terms containsObject:curSymbol]) {
            if (i+j+1 <= str.length && [_grammar.terms containsObject:[[str substringWithRange:NSMakeRange(i, j+1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
                continue;
            }
            [result addObject:curSymbol];
            i += j;
            j = 0;
        }
    }
    
    return [NSArray arrayWithArray:result];
}

#pragma mark steps
-(void)treeGrowth
{
    // No... No... No state change
    // No... No... No cur change
    NSString *nterm = _l2[0];
    NSArray *alt = _alternatives[nterm][0];
    [_l1 addObject:@[nterm, @0]];
    [_l2 removeObjectAtIndex:0];
    for (NSUInteger i=0; i<alt.count; ++i) {
        [_l2 insertObject:alt[i] atIndex:i];
    }
}
-(void)successfulComparison
{
    // No... No... No state change
    ++_cur;
    [_l1 addObject:_l2[0]];
    [_l2 removeObjectAtIndex:0];
}
-(void)successfulFinish
{
    _state = BottomReturningStateFin;
    // No... No... No cur change
    // No... No... No l1 change
    // No... No... No l2 change
}
-(void)failedComparison
{
    _state = BottomReturningStateRet;
    // No... No... No cur change
    // No... No... No l1 change
    // No... No... No l2 change
}
-(void)enterRet
{
    // No... No... No state change
    --_cur;
    [_l2 insertObject:_l1.lastObject atIndex:0];
    [_l1 removeLastObject];
}
-(BOOL)yetAnotherChallenge
{
    BOOL isUnaccepted = NO;
    NSArray *lastAltInfo = [_l1 lastObject];
    NSString *nterm = lastAltInfo[0];
    NSUInteger lastAlt = [lastAltInfo[1] unsignedLongLongValue];
    NSArray *alts = _alternatives[nterm];
    if (alts.count == lastAlt+1) {
        if (_cur == 0 && [nterm isEqualTo:_grammar.axiom]) {
            isUnaccepted = YES;
        } else {
            // No... No... No state change
            // No... No... No cur change
            [_l1 removeLastObject];
            [_l2 removeObjectsInRange:NSMakeRange(0, [alts[lastAlt] count])];
            [_l2 insertObject:nterm atIndex:0];
        }
    } else {
        _state = BottomReturningStateNorm;
        // No... No... No cur change
        [_l1 removeLastObject];
        [_l1 addObject:@[nterm, @(lastAlt+1)]];
        [_l2 removeObjectsInRange:NSMakeRange(0, [alts[lastAlt] count])];
        NSArray *alt = alts[lastAlt+1];
        for (NSUInteger i=0; i<alt.count; ++i) {
            [_l2 insertObject:alt[i] atIndex:i];
        }
    }
    return isUnaccepted;
}

@end
