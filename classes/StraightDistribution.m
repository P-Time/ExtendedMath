//
//  StraightDistribution.m
//  
//
//  Created by Peter Wegener on 03.02.16.
//  Copyright © 2016 Peter Wegener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StraightDistribution.h"
#import "ExtendedMath.h"

static double DEFAULT_INVERSE_ABSOLUTE_ACCURACY = (double)1.0E-9;

@interface StraightDistribution()

    @property (nonatomic) double degreesOfFreedom;
    @property (nonatomic) double solverAbsoluteAccuracy;
    @property (nonatomic) double factor;
@property (nonatomic) ExtendedMath *extMath;

@end

@implementation StraightDistribution
@synthesize degreesOfFreedom, solverAbsoluteAccuracy, factor, extMath;

- (instancetype)initWithDegreesOfFreedom:(double)degrees{
    
    self = [super init];
    
    if (self){
        self.degreesOfFreedom = degrees;
        self.extMath = [[ExtendedMath alloc] init];
    }
    
    return self;
}

- (instancetype)initWithDegreesOfFreedom:(double)degrees andInverseCumAccuracy:(double)accuracy{
    
    self = [super init];
    
    if (self){
        self.degreesOfFreedom = degrees;
        self.solverAbsoluteAccuracy = accuracy;
    }
    
    return self;
}


- (double)getDegreesOfFreedom{
    return self.degreesOfFreedom;
}

- (double)density:(double) x{
    return exp([self logDensity:x]);
}

- (double)logDensity:(double)x{
    double n = self.degreesOfFreedom;
    double nPlus1Over2 = (n + (double)1.0) / (double)2.0;
    return self.factor - nPlus1Over2 * log((double)1.0 + x * x / n);
}

- (double)cumulativeProbability:(double)x{
    double ret;
    if(x == (double)0.0) {
        ret = (double)0.5;
    } else {
        double t = [self regulazedBetaWithParamX:(self.degreesOfFreedom / (self.degreesOfFreedom + x * x)) paramA:(double)0.5 * self.degreesOfFreedom paramB:(double)0.5 epsilon:(double)1.0E-14 andMaxIterations:2147483647];
        if(x < (double)0.0) {
            ret = (double)0.5 * t;
        } else {
            ret = (double)1.0 - (double)0.5 * t;
        }
    }
    
    return ret;
}

- (double)getSolverAbsoluteAccuracy{
    return self.solverAbsoluteAccuracy;
}

- (double)getNumericalMean{
    double df = self.degreesOfFreedom;
    return df > (double)1.0?(double)0.0:(double)0.0 / 0.0;
}

- (double)getNumericalVariance{
    double df = self.degreesOfFreedom;
    return df > (double)2.0?df / (df - (double)2.0):(df > (double)1.0 && df <= (double)2.0?(double)1.0 / 0.0:(double)0.0 / 0.0);
}

- (double)getSupportLowerBound{
    return (double)-1.0 / 0.0;
}

- (double)getSupportUpperBound{
    return (double)1.0 / 0.0;
}

- (Boolean)isSupportLowerBoundInclusive{
    return false;
}

- (Boolean)isSupportUpperBoundInclusive{
    return false;
}

- (Boolean)isSupportConnected{
    return true;
}

- (double)regulazedBetaWithParamX:(double)x paramA:(double)a paramB:(double)b epsilon:(double)epsilon andMaxIterations:(int)maxIterations{
        double ret;
    
    
        if(!(double)isnan(x) && !(double)isnan(a) && !(double)isnan(b) && x >= (double)0.0 && x <= (double)1.0 && a > (double)0.0 && b > (double)0.0) {
            if(x > (a + (double)1.0) / ((double)2.0 + b + a) && (double)1.0 - x <= (b + (double)1.0) / ((double)2.0 + b + a)) {
                ret = (double)1.0 - [self regulazedBetaWithParamX:(double)1.0-x paramA:a paramB:b epsilon:epsilon andMaxIterations:maxIterations];
            } else {
                double(^getB)(int, double) = ^(int n, double x) {
                    double ret;
                    double m;
                    if(n % 2 == 0) {
                        m = (double)n / (double)2.0;
                        ret = m * (b - m) * x / ((a + (double)2.0 * m - (double)1.0) * (a + (double)2.0 * m));
                    } else {
                        m = ((double)n - (double)1.0) / (double)2.0;
                        ret = -((a + m) * (a + b + m) * x) / ((a + (double)2.0 * m) * (a + (double)2.0 * m + (double)1.0));
                    }
                    
                    return ret;
                };
                
                ret = exp(a * log(x) + b * log1p(-x) - log(a)) * (double)1.0 / [extMath evaluateFractions:x withEpsilon:epsilon andMaxIterations:maxIterations];
            }
        } else {
            ret = (double)0.0 / 0.0;
        }
        
        return ret;
}

@end