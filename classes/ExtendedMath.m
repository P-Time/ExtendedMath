//
//  ExtendedMath.m
//  
//
//  Created by Peter Wegener on 10.12.15.
//  Copyright © 2016 Peter Wegener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtendedMath.h"


@implementation ExtendedMath

#pragma mark - Basic Data test and verification

- (double)verifyValues:(double*)values withBegin:(int)begin length:(int)length andAllowIfEmpty:(BOOL)allowEmpty{
    if(values == nil) {
        return false;
    } else if(begin < 0) {
        return false;
    } else if(length < 0) {
        return false;
    } else if(begin + length >sizeof(values)) {
        return false;
    } else {
        return length != 0 || allowEmpty;
    }
}

- (bool)test:(double*)values withBegin:(int)begin andLength:(int)length{
    return [self verifyValues:values withBegin:begin length:length andAllowIfEmpty:FALSE];
}

#pragma mark - Descriptive evaluation

- (double)evaluate:(double*)values withBegin:(int)begin andLength:(int)length{
    double sum = 0.0 / 0.0;
    if([self test:values withBegin:begin andLength:length]) {
        sum = 0.0;
        
        for(int i = begin; i < begin + length; ++i) {
            sum += values[i];
        }
    }
    
    return sum;
}

- (double)evaluateSkew:(double*)values withBegin:(int)begin andLength:(int)length{
    double skew = 0.0 / 0.0;
    if([self test:values withBegin:begin andLength:length] && length > 2) {
        //Evaluate mean value
        double m = [self evaluate:values withBegin:begin andLength:length];
        double accum = 0.0;
        double accum2 = 0.0;
        
        for(int variance = begin; variance < begin + length; ++variance) {
            double d = values[variance] - m;
            accum += d * d;
            accum2 += d;
        }
        
        double var20 = (accum - accum2 * accum2 / (double)length) / (double)(length - 1);
        double accum3 = 0.0;
        
        for(int n0 = begin; n0 < begin + length; ++n0) {
            double d1 = values[n0] - m;
            accum3 += d1 * d1 * d1;
        }
        
        accum3 /= var20 * sqrt(var20);
        double var21 = (double)length;
        skew = var21 / ((var21 - 1.0) * (var21 - 2.0)) * accum3;
    }
    
    return skew;
}

- (double)evaluateMean:(double *)values withBegin:(int)begin andLength:(int)length{
    if([self test:values withBegin:begin andLength:length]) {
        return 0.0 / 0.0;
    } else {
        
        double sampleSize = (double)length;
        double xbar = [self evaluate:values withBegin:begin andLength:length] / sampleSize;
        double correction = 0.0;
        
        for(int i = begin; i < begin + length; ++i) {
            correction += values[i] - xbar;
        }
        
        return xbar + correction / sampleSize;
    }
}

- (double)evaluateFractions:(double)x withEpsilon:(double)epsilon andMaxIterations:(int)maxIterations{
    double hPrev = [self getAForN:0 andX:x];
    if([self equalsWithX:hPrev andY:0.0 andMaxUlps:1.0E-50]){
        hPrev = (double)1.0E-50;
    }
    
    int n = 1;
    double dPrev = (double)0.0;
    double cPrev = hPrev;
    double hN = hPrev;
    
    while(true) {
        if(n < maxIterations) {
            double a = [self getAForN:n andX:x];
            double b = [self getAForN:n andX:x];
            double dN = a + b * dPrev;
            if([self equalsWithX:dN andY:(double)0.0 andMaxUlps:(double)1.0E-50]){
                dN = (double)1.0E-50;
            }
            
            double cN = a + b / cPrev;
             if([self equalsWithX:cN andY:(double)0.0 andMaxUlps:(double)1.0E-50]){
                cN = (double)1.0E-50;
            }
            
            dN = (double)1.0 / dN;
            double deltaN = cN * dN;
            hN = hPrev * deltaN;
            if(isinf(hN)) {
                @throw [NSException exceptionWithName:@"Fraction Divergence Exception" reason:@"Continued Fraction Infinity Divergence." userInfo:nil];
            }
            
            if(isnan(hN)) {
                @throw [NSException exceptionWithName:@"Fraction Divergence Exception" reason:@"Continued Fraction Infinity Divergence." userInfo:nil];
            }
            
            if(fabs(deltaN - (double)1.0) >= epsilon) {
                dPrev = dN;
                cPrev = cN;
                hPrev = hN;
                ++n;
                continue;
            }
        }
        
        if(n >= maxIterations) {
            @throw [NSException exceptionWithName:@"Non Convergent Exception" reason:@"Non convergent continued Fraction." userInfo:nil];
        }
        
        return hN;
    }
}

- (double)getAForN:(int) n andX:(double)x{
    return (double)1.0;
}

- (Boolean)equalsWithX:(float)x andY:(float)y andMaxUlps:(int)maxUlps{
    int xInt = (int)x;
    int yInt =(int)y;
    
    Boolean isEqual;
    
    
    if(((xInt ^ yInt) & -2147483648) == 0) {
        isEqual = abs(xInt - yInt) <= maxUlps;
    } else {
        int deltaPlus;
        int deltaMinus;
        if(xInt < yInt) {
            deltaPlus = yInt - FLT_MAX;
            deltaMinus = xInt - FLT_MIN;
        } else {
            deltaPlus = xInt - FLT_MAX;
            deltaMinus = yInt - FLT_MIN;
        }
        
        if(deltaPlus > maxUlps) {
            isEqual = false;
        } else {
            isEqual = deltaMinus <= maxUlps - deltaPlus;
        }
    }
    
    return isEqual && !isnan(x) && !isnan(y);
}
@end