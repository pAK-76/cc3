//
//  Grammar.m
//  СС1
//
//  Created by Pavel Aksenkin on 24.02.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import "Grammar.h"




@implementation Rule
@synthesize antecedent = _antecedent;
@synthesize consequent = _consequent;

+(Rule *)ruleFrom:(NSString *)from to:(NSArray *)to
{
    Rule *result = [[Rule alloc] init];
    result->_antecedent = from;
    result->_consequent = to;
    return result;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ -> %@", _antecedent, [_consequent componentsJoinedByString:@" "]];
}
-(id)copy
{
    Rule *rule = [[Rule alloc] init];
    rule->_antecedent = self->_antecedent;
    rule->_consequent = self->_consequent;
    return rule;
}
-(BOOL)isEqualTo:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    Rule *another = (Rule*)object;
    return [_antecedent isEqualToString:another->_antecedent]
        && [_consequent isEqualTo:another->_consequent];
}
@end



@implementation Grammar

static Grammar *_instance;

#define EMPTY_STRING @"λ"
NSString * const kEmptyString = EMPTY_STRING;

+(Grammar *)instance
{
    if (!_instance) {
        _instance = [[Grammar alloc] init];
    }
    return _instance;
}

-(id)initFromFile
{
    self = [super init];
    if (self) {
        NSString *file = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"grammar" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        NSArray *strs = [file componentsSeparatedByString:@"\n"];
        NSMutableArray *terms = [NSMutableArray array];
        for(NSUInteger i=0; i<22; ++i) {
            NSString *term = strs[i];
            [terms addObject:term];
        }
        _terms = [NSArray arrayWithArray:terms];
        
        NSMutableArray *nterms = [NSMutableArray array];
        for(NSUInteger i=23; i<31; ++i) {
            NSString *nterm = strs[i];
            [nterms addObject:nterm];
        }
        _nterms = [NSArray arrayWithArray:nterms];
        _axiom = _nterms[0];
        
        NSMutableArray *rules = [NSMutableArray array];
        for(NSUInteger i=32; i<60; ++i) {
            NSString *ruleRaw = strs[i];
            NSArray *ruleComponents = [ruleRaw componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *antecedent = _nterms[[ruleComponents[0] intValue]];
            
            NSMutableArray *consequent = [NSMutableArray array];
            for(NSUInteger i=1; i<ruleComponents.count; ++i) {
                NSString *comp = ruleComponents[i];
                if ([[comp substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"n"]) {
                    [consequent addObject:_nterms[[[comp substringFromIndex:1] intValue]]];
                } else {
                    [consequent addObject:_terms[[[comp substringFromIndex:1] intValue]]];
                }
            }
            
            [rules addObject:[Rule ruleFrom:antecedent to:consequent]];
        }
        _rules = [NSArray arrayWithArray:rules];
    }
    
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        _terms = @[
                  @"a",     //0
                  @"x",     //1
                  @"=",     //2
                  @"<>",    //3
                  @">",     //4
                  @"<",     //5
                  @">=",    //6
                  @"<=",    //7
                  @"+",     //8
                  @"-",     //9
                  @"||",    //10
                  @"or",    //11
                  @"*",     //12
                  @"/",     //13
                  @"div",   //14
                  @"%",     //15
                  @"mod",   //16
                  @"&&",    //17
                  @"and",   //18
                  @"(",     //19
                  @")",     //20
                  @"not"    //21
        ];
        _axiom = @"<Выражение>";
        _nterms = @[
                   _axiom,                      //0
                   @"<Простое выражение>",      //1
                   @"<Терм>",                   //2
                   @"<Фактор>",                 //3
                   @"<Операция отношения>",     //4
                   @"<Знак>",                   //5
                   @"<Операция типа сложения>", //6
                   @"<Операция типа умножения>" //7
        ];
        _rules = @[
                   [Rule ruleFrom:_nterms[0] to:@[ _nterms[1] ]],
                   [Rule ruleFrom:_nterms[0] to:@[ _nterms[1], _nterms[4], _nterms[1] ]],
                   [Rule ruleFrom:_nterms[1] to:@[ _nterms[2] ]],
                   [Rule ruleFrom:_nterms[1] to:@[ _nterms[5], _nterms[2] ]],
                   [Rule ruleFrom:_nterms[1] to:@[ _nterms[1], _nterms[6], _nterms[2] ]],
                   [Rule ruleFrom:_nterms[2] to:@[ _nterms[3] ]],
                   [Rule ruleFrom:_nterms[2] to:@[ _nterms[2], _nterms[7], _nterms[3] ]],
                   [Rule ruleFrom:_nterms[3] to:@[ _terms[0] ]],
                   [Rule ruleFrom:_nterms[3] to:@[ _terms[1] ]],
                   [Rule ruleFrom:_nterms[3] to:@[ _terms[19], _nterms[1], _terms[20] ]],
                   [Rule ruleFrom:_nterms[3] to:@[ _terms[21], _nterms[3] ]],
                   [Rule ruleFrom:_nterms[4] to:@[ _terms[2] ]],
                   [Rule ruleFrom:_nterms[4] to:@[ _terms[3] ]],
                   [Rule ruleFrom:_nterms[4] to:@[ _terms[4] ]],
                   [Rule ruleFrom:_nterms[4] to:@[ _terms[5] ]],
                   [Rule ruleFrom:_nterms[4] to:@[ _terms[6] ]],
                   [Rule ruleFrom:_nterms[4] to:@[ _terms[7] ]],
                   [Rule ruleFrom:_nterms[5] to:@[ _terms[8] ]],
                   [Rule ruleFrom:_nterms[5] to:@[ _terms[9] ]],
                   [Rule ruleFrom:_nterms[6] to:@[ _terms[8] ]],
                   [Rule ruleFrom:_nterms[6] to:@[ _terms[9] ]],
                   [Rule ruleFrom:_nterms[6] to:@[ _terms[10] ]],
                   [Rule ruleFrom:_nterms[6] to:@[ _terms[11] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[12] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[13] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[14] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[15] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[16] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[17] ]],
                   [Rule ruleFrom:_nterms[7] to:@[ _terms[18] ]]
        ];
    }
    return self;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self descriptionStrings].count;
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self descriptionStrings][row];
}
-(NSArray*)descriptionStrings
{
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:[super description]];
    [result addObject:[NSString stringWithFormat:@"Терминалы: %@", [_terms componentsJoinedByString:@", "]]];
    [result addObject:@""];
    [result addObject:[NSString stringWithFormat:@"Нетерминалы: %@", [_nterms componentsJoinedByString:@", "]]];
    [result addObject:@""];
    [result addObject:[NSString stringWithFormat:@"Аксиома: %@", _axiom]];
    [result addObject:@""];
    [result addObject:@"Правила:"];
    for (Rule *rule in _rules) {
        [result addObject:[NSString stringWithFormat:@"%@", rule]];
    }
    return [NSArray arrayWithArray:result];
}
-(NSString *)description
{
    return [[self descriptionStrings] componentsJoinedByString:@"\n"];
}

-(void)removeLeftRecursy
{
    NSMutableArray *newRules = [NSMutableArray array];
    NSMutableArray *newNterms = [NSMutableArray array];
    for (NSUInteger i=0; i<_nterms.count; ++i) {
        NSString *nterm = [_nterms[i] copy];
        NSArray *alts = [self rulesFor:nterm];
        
            // Прямая левая рекурсия
        BOOL hasLeft = NO;
        for (Rule *rule in alts) {
            if ([rule.consequent[0] isEqualTo:nterm]) {
                hasLeft = YES;
                break;
            }
        }
        NSMutableArray *curNewRules = [NSMutableArray array];
        if (hasLeft) {
            [newNterms addObject:nterm];
            NSString *nnterm = [[nterm substringToIndex:nterm.length-1] stringByAppendingString:@"2>"];
            [newNterms addObject:nnterm];
            for (Rule *rule in alts) {
                if ([rule.consequent[0] isEqualTo:nterm]) {
                    NSMutableArray *cons = [rule.consequent mutableCopy];
                    [cons removeObjectAtIndex:0];
                    Rule *r1 = [Rule ruleFrom:nnterm to:[NSArray arrayWithArray:cons]];
                    [curNewRules addObject:r1];
                    
                    [cons addObject:nnterm];
                    Rule *r2 = [Rule ruleFrom:nnterm to:[NSArray arrayWithArray:cons]];
                    [curNewRules addObject:r2];
                } else {
                    NSMutableArray *cons = [rule.consequent mutableCopy];
                    Rule *r1 = [Rule ruleFrom:nterm to:[NSArray arrayWithArray:cons]];
                    [curNewRules addObject:r1];
                    
                    [cons addObject:nnterm];
                    Rule *r2 = [Rule ruleFrom:nterm to:[NSArray arrayWithArray:cons]];
                    [curNewRules addObject:r2];
                }
            }
        } else {
            [newNterms addObject:nterm];
            [curNewRules addObjectsFromArray:alts];
        }
        
        /*    // Непрямая левая рекурсия
        NSUInteger oldCount = curNewRules.count;
        for (i=0; i<oldCount; ) {
            NSLog(@"Nterm: %@", nterm);
            Rule *rule = curNewRules[i];
            NSUInteger j = [_nterms indexOfObject:rule.consequent[0]];
            if (j != -1 && j < i) {
                NSArray *alts = [self alternativesFor:_nterms[j] from:newRules];
                for (NSArray *alt in alts) {
                    NSMutableArray *newCons = [NSMutableArray arrayWithArray:alt];
                    for(NSUInteger k=1; k<rule.consequent.count; ++k) {
                        [newCons addObject:rule.consequent[k]];
                    }
                    [curNewRules addObject:[Rule ruleFrom:nterm to:[NSArray arrayWithArray:newCons]]];
                }
                [curNewRules removeObjectAtIndex:i];
                --oldCount;
            } else {
                ++i;
            }
        }*/
        
        [newRules addObjectsFromArray:curNewRules];
    }
    
    _rules = [newRules copy];
    _nterms = [newNterms copy];
}

#pragma mark getters
-(NSArray *)terms
{
    return _terms;
}
-(NSArray *)nterms
{
    return _nterms;
}
-(NSString *)axiom
{
    return _axiom;
}
-(NSArray *)rules
{
    return _rules;
}

-(NSArray *)alternativesFor:(NSString *)nterm
{
    return [self alternativesFor:nterm from:_rules];
}
-(NSArray *)alternativesFor:(NSString *)nterm from:(NSArray*)rules
{
    NSMutableArray *result = [NSMutableArray array];
    for (Rule *rule in rules) {
        if ([rule.antecedent isEqualTo:nterm]) {
            [result addObject:rule.consequent];
        }
    }
    return [NSArray arrayWithArray:result];
}
-(NSArray *)rulesFor:(NSString *)nterm
{
    return [self rulesFor:nterm from:_rules];
}
-(NSArray *)rulesFor:(NSString *)nterm from:(NSArray*)rules
{
    NSMutableArray *result = [NSMutableArray array];
    for (Rule *rule in rules) {
        if ([rule.antecedent isEqualTo:nterm]) {
            [result addObject:rule];
        }
    }
    return [NSArray arrayWithArray:result];
}

@end
