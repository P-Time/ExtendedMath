//
//  Statistics.h
//  
//
//  Created by Peter Wegener on 10.12.15.
//  Copyright © 2015 Peter Wegener. All rights reserved.
//

#import "ExtendedMath.h"

@interface Statistics : ExtendedMath{
        NSUInteger count;
        NSUInteger minIdx;
        NSUInteger maxIdx;

        double min;
        double max;
        double mean;

        @private
        double pseudoVariance;
}

// Custom init methods //
- (id)initWithData:(id)x;

- (id)initWithArray:(NSArray*)array;

// Add straight data point //
- (void)addDouble:(double)d;

// Add Data point from object //
- (void)addData:(id)x;

// Add Data points from straight array (immutable) //
- (void)addDataFromArray:(NSArray*)x;

// Count of DataPoints //
@property(readonly) NSUInteger count;

// Index of smallest data point //
@property(readonly) NSUInteger minIdx;

// Index of largest data point //
@property(readonly) NSUInteger maxIdx;

// Value of smallest data point //
@property(readonly) double min;

// Value of largest data point //
@property(readonly) double max;

// The descriptive mean //
@property(readonly) double mean;

// Exceptional Range from Max to Min //
- (double)range;

// Statistical Variance //
- (double)variance;

// Statistical biased Variance //
- (double)biasedVariance;

// Statistical Deviation //
- (double)standardDeviation;

// Standard deviation of population by devision n //
- (double)biasedStandardDeviation;

@end