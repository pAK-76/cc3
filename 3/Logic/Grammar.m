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

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ -> %@", _antecedent, _consequent];
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
        && [_consequent isEqualToString:another->_consequent];
}
@end

@implementation Grammar

#define EMPTY_STRING @"λ"

NSString * const kNTerminals  = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
NSString * const kTerminals = @"abcdefghijklmnopqrstuvwxyz+-*/";
NSString * const kEmptyString = EMPTY_STRING;
NSString * const kKSRulePattern = @"[A-Z] ?-> ?[A-Za-z+\\-*/"EMPTY_STRING@"]*?";

-(Grammar *)initWithStrings:(NSArray *)strings axiom:(NSString *)axiom
{
    self = [self initWithStrings:strings];
    if (self) {
        _axiom = axiom;
    }
    return self;
}
-(Grammar *)initWithStrings:(NSArray *)strings
{
    self = [super init];
    if (self) {
        _terms = [[NSMutableArray alloc] init];
        _nterms = [[NSMutableArray alloc] init];
        _rules = [[NSMutableArray alloc] init];
        for (NSString *str in strings) {
            NSArray * comps = [str componentsSeparatedByString:@"->"];
            assert(comps.count == 2);
            Rule *rule = [[Rule alloc] init];
            rule.antecedent = [comps[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            rule.consequent = [comps[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [_rules addObject:rule];
            for(NSUInteger i=0; i<rule.antecedent.length; ++i) {
                NSString *symbol = [rule.antecedent substringWithRange:NSMakeRange(i, 1)];
                if ([kNTerminals rangeOfString:symbol].location != NSNotFound) {
                    if (![_nterms containsObject:symbol]) {
                        [_nterms addObject:symbol];
                    }
                } else {
                    NSLog(@"Antecedent contains forbidden symbols");
                }
            }
            for(NSUInteger i=0; i<rule.consequent.length; ++i) {
                NSString *symbol = [rule.consequent substringWithRange:NSMakeRange(i, 1)];
                if ([kNTerminals rangeOfString:symbol].location != NSNotFound) {
                    if (![_nterms containsObject:symbol]) {
                        [_nterms addObject:symbol];
                    }
                } else if ([kTerminals rangeOfString:symbol].location != NSNotFound) {
                    if (![_terms containsObject:symbol]) {
                        [_terms addObject:symbol];
                    }
                } else if (![symbol isEqualToString:kEmptyString]) {
                    NSLog(@"Consequent contains forbidden symbols");
                }
            }
            
            if ([_nterms containsObject:@"S"]) {
                _axiom = @"S";
            } else if ([_nterms containsObject:@"A"]) {
                _axiom = @"A";
            } else {
                _axiom = _nterms[0];
            }
        }
    }
    
    return self;
}

-(NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@", [super description]];
    
    NSMutableString *terms = [[NSMutableString alloc] initWithString:@"Терминалы: "];
    for (NSString *term in _terms) {
        [terms appendString:term];
    }
    [description appendFormat:@"\n%@", terms];
    
    NSMutableString *nterms = [[NSMutableString alloc] initWithString:@"Нетерминалы: "];
    for (NSString *nterm in _nterms) {
        [nterms appendString:nterm];
    }
    [description appendFormat:@"\n%@", nterms];
    [description appendFormat:@"\nАксиома: %@", _axiom];
    
    [description appendString:@"\nПравила: "];
    for (Rule *rule in _rules) {
        [description appendFormat:@"\n%@", rule];
    }
    [description appendString:@"\n\n"];
    
    return description;
}

#pragma mark getters
-(NSArray *)terms
{
    return [NSArray arrayWithArray:_terms];
}
-(NSArray *)nterms
{
    return [NSArray arrayWithArray:_nterms];
}
-(NSString *)axiom
{
    return _axiom;
}
-(NSArray *)rules
{
    return [NSArray arrayWithArray:_rules];
}

#pragma mark algorithms
-(BOOL)_set:(NSMutableArray*)set containsObject:(id)object
{
    BOOL result = NO;
    for (id obj in set) {
        if ([obj isEqualTo:object]) {
            result = YES;
            break;
        }
    }
    return result;
}

@end
