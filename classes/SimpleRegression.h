//
//  SimpleRegression.h
//
//
//  Created by Peter Wegener on 15.01.16.
//  Copyright © 2016 Peter Wegener. All rights reserved.
//

@interface SimpleRegression : NSObject
+ (instancetype)regression;

- (void)addDataX:(double)x andY:(double)y;
- (void)append:(SimpleRegression*)reg;
- (void)removeDataForX:(double)x andY:(double)y;
- (void)addData:(double**) data;
- (void)addObservationForX:(double*) x andY:(double)y;
- (void)addObservationsForX:(double**)x andY:(double*)y;
- (void)clear;
- (long)getN;
- (double)predict:(double)x;
- (double)getIntercept;
- (Boolean)hasIntercept;
- (double)getSlope;
- (double)getSumSquaredErrors;
- (double)getTotalSumSquares;
- (double)getXSumSquares;
- (double)getSumOfCrossProducts;
- (double)getRegressionSumSquares;
- (double)getMeanSquareError;
- (double)getR;
- (double)getRSquare;
- (double)getInterceptStdErr;
- (double)getSlopeStdErr;
- (double)getSlopeConfidenceInterval;
- (double)getSlopeConfidenceInterval:(double)alpha;
- (double)getSignificance;
- (double)getIntercept:(double)slope;
- (double)getRegressionSumSquares:(double)slope;

@end