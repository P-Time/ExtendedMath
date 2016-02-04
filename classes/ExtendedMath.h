//
//  ExtendedMath.h
//  
//
//  Created by Peter Wegener on 10.12.15.
//  Copyright © 2016 Peter Wegener. All rights reserved.
//

@interface ExtendedMath : NSObject

//Descriptive verification of Mean and Median values
- (double)verifyValues:(double*)values withBegin:(int)begin length:(int)length andAllowIfEmpty:(BOOL)allowEmpty;

- (bool)test:(double*)values withBegin:(int)begin andLength:(int)length;

//Descriptive Sum Function
- (double)evaluate:(double*)values withBegin:(int)begin andLength:(int)length;

//Evaluation in descriptive combination of Skew and Mean
- (double)evaluateSkew:(double*)values withBegin:(int)begin andLength:(int)length;

- (double)evaluateMean:(double*)values withBegin:(int)begin andLength:(int)length;

- (double)evaluateFractions:(double)x withEpsilon:(double)epsilon andMaxIterations:(int)maxIterations;
@end
