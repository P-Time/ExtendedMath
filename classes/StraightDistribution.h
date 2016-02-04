//
//  StraightDistribution.h
//  
//
//  Created by Peter Wegener on 03.02.16.
//  Copyright © 2016 Peter Wegener. All rights reserved.
//

@interface StraightDistribution : NSObject
- (instancetype)initWithDegreesOfFreedom:(double)degrees;
- (instancetype)initWithDegreesOfFreedom:(double)degrees andInverseCumAccuracy:(double)accuracy;

- (double)getDegreesOfFreedom;
- (double)density:(double)x;
- (double)logDensity:(double)x;
- (double)cumulativeProbability:(double)x;
- (double)getSolverAbsoluteAccuracy;
- (double)getNumericalMean;
- (double)getNumericalVariance;
- (double)getSupportLowerBound;
- (double)getSupportUpperBound;
- (Boolean)isSupportLowerBoundInclusive;
- (Boolean)isSupportUpperBoundInclusive;
- (Boolean)isSupportConnected;

- (double)regulazedBetaWithParamX:(double)x paramA:(double)a paramB:(double)b epsilon:(double)epsilon andMaxIterations:(int)maxIterations;

@end