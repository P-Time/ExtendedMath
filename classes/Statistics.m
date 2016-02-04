//
//  Statistics.m
//  
//
//  Created by Peter Wegener on 10.12.15.
//  Copyright © 2015 Peter Wegener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Statistics.h"

@implementation Statistics

@synthesize count;
@synthesize minIdx;
@synthesize maxIdx;

@synthesize min;
@synthesize max;
@synthesize mean;

#pragma mark Initialisation

- (id)init
{
    self = [super init];
    if (self) {
        min = max = mean = nan(0);
    }
    return self;
}

// Init objects with data structure(s) //
- (id)initWithData:(id)x
{
    if (self = [super init]) {
        NSAssert([x respondsToSelector:@selector(doubleValue)], @"Data must respond to -doubleValue");
        [self addDouble:[x doubleValue]];
    }
    return self;
}

- (id)initWithArray:(NSArray*)array
{
    if (self = [super init]) {
        for (id x in array)
            [self addData:x];
    }
    return self;
}

#pragma mark - Adding data
- (void)addDataFromArray:(NSArray*)array
{
    for (id x in array)
        [self addData:x];
}

// DataPoint must have the double Value selector
- (void)addData:(id)x
{
    NSAssert([x respondsToSelector:@selector(doubleValue)], @"Data must respond to -doubleValue");
    [self addDouble:[x doubleValue]];
}

- (void)addDouble:(double)d {
    if (!count) {
        min = INFINITY;
        max = -min;
        mean = 0;
    }
    
    if (d < min) {
        min = d;
        minIdx = count;
    }
    if (d > max) {
        max = d;
        maxIdx = count;
    }
    
    double oldMean = mean;
    mean += (d - oldMean) / ++count;
    pseudoVariance += (d - mean) * (d - oldMean);
}

#pragma mark - Descriptive Methods
- (double)range
{
    return max - min;
}

- (double)variance
{
    if (count > 1)
        return pseudoVariance / (count - 1);
    return nan(0);
}

- (double)biasedVariance
{
    if (count > 1)
        return pseudoVariance / count;
    return nan(0);
}

- (double)standardDeviation
{
    return sqrt([self variance]);
}

- (double)biasedStandardDeviation
{
    return sqrt([self biasedVariance]);
}



@end