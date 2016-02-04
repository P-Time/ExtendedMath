//
//  Mean.h
//  blceaccesssystem
//
//  Created by Peter Wegener on 20.11.15.
//  Copyright © 2015 Peter Wegener. All rights reserved.
//

#import "Statistics.h"

@interface DescriptiveStatistics : Statistics

/// Most frequently occuring data point
- (double)mode;

/// Middle value in a list of sorted data points
- (double)median;

/// Find the largest data point less than a certain percentage
- (double)percentile:(double)x;

- (double)harmonicMean;

- (double)geometricMean;

// Returns an (optionally cumulative) frequency distribution.
- (NSDictionary*)frequencyDistributionWithBuckets:(NSArray*)x cumulative:(BOOL)y;

// Returns x equally-sized buckets covering the range of data.
- (NSArray*)bucketsWithCount:(NSUInteger)x;

// Returns N buckets of size x covering the range of data.
- (NSArray*)bucketsWithInterval:(double)x;

// Returns the data in the order it was added.
//- (NSArray*)data;

/// Returns the data in sorted order.
- (NSArray*)sortedData;

// Returns the data sans low and high outliers.
- (NSArray*)sortedDataDiscardingLowOutliers:(double)low high:(double)high;

// Returns a new statistics object, with outliers removed from the data.
- (id)statisticsDiscardingLowOutliers:(double)low high:(double)high;

@end