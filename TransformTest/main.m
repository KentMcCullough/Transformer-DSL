//
//  main.m
//  TransformTest
//
//  Created by Jonathan Wight on 3/6/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMTransformFormatter.h"

static CFAbsoluteTime Time(int count, void (^block)(void))
    {
    CFAbsoluteTime theStart = CFAbsoluteTimeGetCurrent();
    for (int N = 0; N != count; ++N)
        {
        block();
        }
    CFAbsoluteTime theEnd = CFAbsoluteTimeGetCurrent();
    return(theEnd - theStart);
    }

int main(int argc, const char * argv[])
    {
    @autoreleasepool
        {
        int N = 50000;

        CFAbsoluteTime X = Time(N, ^{
            NIMTransformFormatter *theFormatter = [NIMTransformFormatter formatterWithFormat:@"translate(1,2) | scale(10,10,1.0)"];

            [theFormatter CATransform3D];
            });
        NSLog(@"Time for non-parametized expression: %g", X);

        CFAbsoluteTime Y = Time(N, ^{
            NIMTransformFormatter *theFormatter = [NIMTransformFormatter formatterWithFormat:@"translate(1,2) | scale(10,10,%f)", 1.0];

            [theFormatter CATransform3D];
            });
        NSLog(@"Time for parametized expression: %g", Y);

        CFAbsoluteTime Z = Time(N, ^{
            CATransform3DScale(CATransform3DMakeTranslation(1, 2, 0), 10, 10, 1);
            });
        NSLog(@"Time for raw CA function calls: %g", Z);

        NSLog(@"Slow-down factor for non-parametrized: %g", X / Z);
        NSLog(@"Slow-down factor for parametrized: %g", Y / Z);

//        if (CATransform3DEqualToTransform(theTransform, theTransform2) == NO)
//            {
//            NSLog(@"NOT EQUALS");
//            }
        }
    return 0;
    }

