//
//  Grammar.h
//  СС1
//
//  Created by Pavel Aksenkin on 24.02.13.
//  Copyright (c) 2013 Pavel Aksenkin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kEmptyString;

@interface Rule : NSObject

+(Rule*)ruleFrom:(NSString*)from to:(NSArray*)to;

@property (copy) NSString *antecedent;
@property (copy) NSArray *consequent;

@end

@interface Grammar : NSObject <NSTableViewDataSource>
{
    NSArray *_terms;
    NSArray *_nterms;
    NSString *_axiom;
    NSArray *_rules;
}

+(Grammar*)instance;

-(NSArray*)terms;
-(NSArray*)nterms;
-(NSString*)axiom;
-(NSArray*)rules;

-(void)removeLeftRecursy;

-(NSArray*)alternativesFor:(NSString*)nterm;

@end
