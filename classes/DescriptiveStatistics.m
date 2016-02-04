//
//  Mean.m
//  blceaccesssystem
//
//  Created by Peter Wegener on 20.11.2015.
//  Copyright © 2015 Peter Wegener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DescriptiveStatistics.h"
#import "Math.h"

static void incrementValueForKey(NSMutableDictionary *dict, NSNumber *key)
{
    id value = [dict objectForKey:key];
    value = value? [NSNumber numberWithInt:[value intValue] + 1]:[NSNumber numberWithInt:1];
    
    [dict setObject:value forKey:key];
}

@interface DescriptiveStatistics ()

    @property (nonatomic, strong) NSMutableArray *mutableData;
    @property (nonatomic, copy) NSArray *sortedData;

@end


@implementation DescriptiveStatistics

#pragma mark Creation and deletion

- (id)init {
    if ((self = [super init])) {
        self.mutableData = [[NSMutableArray alloc] init];
    }
    return self;
}

/*  This can be used to calculate the truncated mean.
    low has to be a real number such that 0 <= low < 1.
    high has to be a real number such that 0 <= high < 1.
*/
- (id)statisticsDiscardingLowOutliers:(double)low high:(double)high
{
    id copy = [[self class] new];
    [copy addDataFromArray:[self sortedDataDiscardingLowOutliers:low high:high]];
    return copy;
}

#pragma mark Adding data
- (void)addDouble:(double)d
{
    [super addDouble:d];
    [self.mutableData addObject:@(d)];
    
    // Invalidate cached data
    self.sortedData = nil;
}

#pragma mark Returning data

- (NSArray *)data {
    return [self.mutableData copy];
}

- (NSArray*)sortedData
{
    if (nil == _sortedData)
        // Create a cached sorted data array
        self.sortedData = [self.mutableData sortedArrayUsingSelector:@selector(compare:)];
    
    return [_sortedData copy];
}

/*  The parameters low=0.05 and high=0.1 means discarding the lower 5% and
    upper 10% of data. If the params are not in the Range, assert throws an exception 
*/
- (NSArray*)sortedDataDiscardingLowOutliers:(double)low high:(double)high
{
    NSAssert1(low >= 0 && low < 1.0, @"Low bound must be 0 <= x < 1, was %f", low);
    NSAssert1(high >= 0 && high < 1.0, @"High bound must be 0 <= x < 1, was %f", high);
    
    NSUInteger lo = low * count;
    NSUInteger hi = ceil(count - high * count);
    NSRange r = NSMakeRange(lo, hi - lo);
    
    return [[self sortedData] subarrayWithRange:r];
}

#pragma mark Statistics

/* Returns most frequently occuring data point or nan if all the data points are not duplicated */
- (double)mode
{
    id freq = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSNumber *x in self.mutableData)
        incrementValueForKey(freq, x);
    
    // No mode exists if all the numbers are unique
    if ([freq count] == count)
        return nan(0);
    return [[[freq keysSortedByValueUsingSelector:@selector(compare:)] lastObject] doubleValue];
}

//Descriptive implementation of Median
- (double)median
{
    if (!count)
        return nan(0);
    if (count == 1)
        return self.mean;
    
    NSArray *sorted = [self sortedData];
    if (count & 1)
        return [[sorted objectAtIndex:count / 2 - 1] doubleValue];
    return ([[sorted objectAtIndex:count / 2 - 1] doubleValue] + [[sorted objectAtIndex:count / 2] doubleValue]) / 2;
}

//Descriptive implementation of Percentile
- (double)percentile:(double)x
{
    NSAssert1(x >= 0 && x <= 1, @"Value must be 0 <= x <= 1, was %f", x);
    NSUInteger i = (count-1) * x;
    return [[[self sortedData] objectAtIndex:i] doubleValue];
}


// harmonic mean will be undefined if any of the values is zero.
- (double)harmonicMean
{
    long double sum = 0.0;
    for (NSNumber *n in self.mutableData) {
        double d = [n doubleValue];
        if (d == 0)
            return nan(0);
        sum += 1 / d;
    }
    return count / sum;
}

// harmonic mean will be undefined if any of the values is less then zero.
- (double)geometricMean
{
    if (!count)
        return nan(0);
    
    long double sum = 1;
    for (NSNumber *n in self.mutableData) {
        double d = [n doubleValue];
        if (d < 0)
            return nan(0);
        sum *= d;
    }
    return pow(sum, 1.0 / count);
}

/*  Returns a dictionary of frequency distributions for the given
    buckets. The returned dictionary has a key for each of the values
    in @p theBuckets. The associated value is the count of data points 
*/
- (NSDictionary*)frequencyDistributionWithBuckets:(NSArray*)theBuckets cumulative:(BOOL)cumulative
{
    NSAssert([theBuckets count], @"No buckets given");
    
    // Buckets must be NSNumbers
    id buckets = [NSMutableArray arrayWithCapacity:[theBuckets count]];
    for (id b in theBuckets)
        [buckets addObject:[NSNumber numberWithDouble:[b doubleValue]]];
    
    // Create dictionary to hold frequency distribution and initialise each bucket
    id freq = [NSMutableDictionary dictionaryWithCapacity:[buckets count]];
    for (NSNumber *bucket in buckets)
        [freq setObject:[NSNumber numberWithInt:0] forKey:bucket];
    
    // Make sure the buckets are sorted, and prepare an iterator for them
    buckets = [buckets sortedArrayUsingSelector:@selector(compare:)];
    NSEnumerator *biter = [buckets objectEnumerator];
    NSNumber *b = [biter nextObject];
    
    // Determine the frequency for each bucket
    for (NSNumber *n in [self sortedData]) {
    again:
        if ([n compare:b] <= 0) {
            incrementValueForKey(freq, b);
        } else {
            b = [biter nextObject];
            if (b)
                goto again;
        }
    }
    
    if (cumulative) {
        NSUInteger total = 0;
        id cfreq = [NSMutableDictionary dictionaryWithCapacity:[buckets count]];
        for (id key in buckets) {
            total += [[freq objectForKey:key] unsignedIntValue];
            [cfreq setObject:[NSNumber numberWithUnsignedInteger:total] forKey:key];
        }
        freq = cfreq;
    }
    
    return freq;
}

#pragma mark Buckets
- (NSArray*)bucketsWithCount:(NSUInteger)x
{
    return [self bucketsWithInterval:self.range / x];
}

- (NSArray*)bucketsWithInterval:(double)interval
{
    if (!count || interval <= 0)
        return nil;
    
    id buckets = [NSMutableArray arrayWithObject:[NSNumber numberWithDouble:self.max]];
    
    double bucket;
    for (bucket = self.max - interval; bucket > self.min; bucket -= interval)
        [buckets addObject:[NSNumber numberWithDouble:bucket]];
    return buckets;
}





@end