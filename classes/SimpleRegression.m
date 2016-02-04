//
//  SimpleRegression.m
//  
//
//  Created by Peter Wegener on 15.01.16.
//  Copyright © 2016 Peter Wegener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleRegression.h"
#import "Math.h"

@interface SimpleRegression()
@property (nonatomic)  double sumX;
@property (nonatomic)  double sumXX;
@property (nonatomic)  double sumY;
@property (nonatomic)  double sumYY;
@property (nonatomic)  double sumXY;
@property (nonatomic)  long n;
@property (nonatomic)  double xbar;
@property (nonatomic)  double ybar;
@property (nonatomic)  Boolean hasIntercept;
@end

@implementation SimpleRegression
@synthesize sumX, sumXX, sumXY, sumY, sumYY, n, xbar, ybar, hasIntercept;

+ (instancetype)regression{
    
    static SimpleRegression *regression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regression = [[SimpleRegression alloc] init];
    });
    return regression;
}

- (instancetype)initWithIncludeInterceptEnabled:(Boolean)includeIntercept{
    self = [super init];
    
    if(self){
        sumX = (double)0.0;
        sumXX = (double)0.0;
        sumY = (double)0.0;
        sumYY = (double)0.0;
        sumXY = (double)0.0;
        n = (long)0;
        xbar = (double)0.0;
        ybar = (double)0.0;
        hasIntercept = includeIntercept;
    }
    
    return self;
}

- (void)addDataX:(double)x andY:(double)y{
    if(n == (long)0) {
        xbar = x;
        ybar = y;
    } else if(hasIntercept) {
        double fact1 = (double)1.0 + (double)n;
        double fact2 = (double)n / ((double)1.0 + (double)n);
        double dx = x - xbar;
        double dy = y - ybar;
        sumXX += dx * dx * fact2;
        sumYY += dy * dy * fact2;
        sumXY += dx * dy * fact2;
        xbar += dx / fact1;
        ybar += dy / fact1;
    }
    
    if(!hasIntercept) {
        sumXX += x * x;
        sumYY += y * y;
        sumXY += x * y;
    }
    
    sumX += x;
    sumY += y;
    ++n;
}

- (void)append:(SimpleRegression*)reg{
    if(n == (long)0) {
        xbar = reg.xbar;
        ybar = reg.ybar;
        sumXX = reg.sumXX;
        sumYY = reg.sumYY;
        sumXY = reg.sumXY;
    } else if(hasIntercept) {
        double fact1 = (double)reg.n / (double)(reg.n + n);
        double fact2 = (double)(n * reg.n) / (double)(reg.n + n);
        double dx = reg.xbar - xbar;
        double dy = reg.ybar - ybar;
        sumXX += reg.sumXX + dx * dx * fact2;
        sumYY += reg.sumYY + dy * dy * fact2;
        sumXY += reg.sumXY + dx * dy * fact2;
        xbar += dx * fact1;
        ybar += dy * fact1;
    } else {
        sumXX += reg.sumXX;
        sumYY += reg.sumYY;
        sumXY += reg.sumXY;
    }
    
    sumX += reg.sumX;
    sumY += reg.sumY;
    n += reg.n;
}

- (void)removeDataForX:(double)x andY:(double)y{
    if(n > (long)0) {
        double fact1;
        if(hasIntercept) {
            fact1 = (double)n - (double)1.0;
            double fact2 = (double)n / ((double)n - (double)1.0);
            double dx = x - xbar;
            double dy = y - ybar;
            sumXX -= dx * dx * fact2;
            sumYY -= dy * dy * fact2;
            sumXY -= dx * dy * fact2;
            xbar -= dx / fact1;
            ybar -= dy / fact1;
        } else {
            fact1 = (double)n - (double)1.0;
            sumXX -= x * x;
            sumYY -= y * y;
            sumXY -= x * y;
            xbar -= x / fact1;
            ybar -= y / fact1;
        }
        
        sumX -= x;
        sumY -= y;
        --n;
    }
    
}

- (void)addData:(double**) data{
    for(int i = 0; i < sizeof(data); ++i) {
        if(sizeof(data[i]) < 2) {
            @throw[NSException exceptionWithName:@"Invalid Regression Exception" reason:@"Invalid Regression Observation" userInfo:nil];
        }
        
        [self addDataX:data[i][0] andY:data[i][1]];

    }
    
}

- (void)addObservationForX:(double*) x andY:(double)y{
    if(x != nil && sizeof(x) != 0) {
        [self addDataX:x[0] andY:y];
    } else {
        @throw [NSException exceptionWithName:@"Invalid Regression Observation" reason:@"Param was invalid" userInfo:nil];
    }
}

- (void)addObservationsForX:(double**)x andY:(double*)y{
    if(x != nil && y != nil && sizeof(x) == sizeof(y)) {
        Boolean obsOk = true;
        
        int i;
        for(i = 0; i < sizeof(x); ++i) {
            if(x[i] == nil || sizeof(x[i]) == 0) {
                obsOk = false;
            }
        }
        
        if(!obsOk) {
            @throw [NSException exceptionWithName:@"Predicator Exception" reason:@"Not enough Data for Number of Predicators" userInfo:nil];
        } else {
            for(i = 0; i < sizeof(x); ++i) {
                [self addDataX:x[i][0] andY:y[i]];
            }
            
        }
    } else {
        @throw [NSException exceptionWithName:@"Dimension Exception" reason:@"Simple Mismatch of dimensions from param" userInfo:nil];
    }
}

- (void)removeData:(double**) data {
    for(int i = 0; i < sizeof(data) && n > (long)0; ++i) {
//        removeData(data[i][0], data[i][1]);
    }
    
}

- (void)clear{
    sumX = (double)0.0;
    sumXX = (double)0.0;
    sumY = (double)0.0;
    sumYY = (double)0.0;
    sumXY = (double)0.0;
    n = (long)0;
}

- (long)getN{
    return n;
}

- (double)predict:(double)x{
    double b1 = [self getSlope];
    return hasIntercept?[self getIntercept:b1] + b1 * x:b1 * x;
}

- (double)getIntercept{
    return hasIntercept? [self getIntercept:[self getSlope] ]:(double)0.0;
}

- (Boolean)hasIntercept{
    return hasIntercept;
}

- (double)getSlope{
    return n < (long)2 ? ((double)0.0 / 0.0): fabs(sumXX) < (double)4.9E-323 ? ((double)0.0 / 0.0) : (sumXY / sumXX);
}

- (double)getSumSquaredErrors{
    return (double)fmax((long)0.0, sumYY - sumXY * sumXY / sumXX);
}

- (double)getTotalSumSquares{
    return n < (long)2?(double)0.0 / 0.0:sumYY;
}

- (double)getXSumSquares{
    return n < (long)2?(double)0.0 / 0.0:sumXX;
}

- (double)getSumOfCrossProducts{
    return sumXY;
}

- (double)getRegressionSumSquares{
    return [self getRegressionSumSquares:[self getSlope]];
}

- (double)getMeanSquareError{
    return n < (long)3?(double)0.0 / 0.0:(hasIntercept?[self getSumSquaredErrors]/ (double)(n - (long)2):[self getSumSquaredErrors] / (double)(n - (long)1));
}

- (double)getR{
    double b1 = [self getSlope];
    double result = sqrt([self getRSquare]);
    if(b1 < (double)0.0) {
        result = -result;
    }
    
    return result;
}

- (double)getRSquare{
    double ssto = [self getTotalSumSquares];
    return (ssto - [self getSumSquaredErrors]) / ssto;
}

- (double)getInterceptStdErr{
    return !hasIntercept?(double)0.0 / 0.0:sqrt([self getMeanSquareError] * ((double)1.0 / (double)n + xbar * xbar / sumXX));
}

- (double)getSlopeStdErr{
    return sqrt([self getMeanSquareError] / sumXX);
}

- (double)getSlopeConfidenceInterval{
    return [self getSlopeConfidenceInterval:(double)0.05];
}

- (double)getSlopeConfidenceInterval:(double)alpha{
    if(n < 3L) {
        return (double)0.0 / 0.0;
    } else if(alpha < (double)1.0 && alpha > (double)0.0) {
        return [self getSlopeStdErr];
    } else {
        @throw [NSException exceptionWithName:@"Out of Range Exception" reason:@"Data out of range for param alpha" userInfo:nil];
    }
    return (double)0.0;
}

- (double)getSignificance{
    if(n < (long)3) {
        return (double)0.0 / 0.0;
    } else {
        return (double)2.0;
    }
}

- (double)getIntercept:(double)slope{
    return hasIntercept?(sumY - slope * sumX) / (double)n:(double)0.0;
}

- (double)getRegressionSumSquares:(double)slope{
    return slope * slope * sumXX;
}


@end