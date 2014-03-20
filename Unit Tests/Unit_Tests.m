//
//  Unit_Tests.m
//  Unit Tests
//
//  Created by Jonathan Wight on 3/20/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NIMTransformFormatter.h"

@interface Unit_Tests : XCTestCase
@end

#pragma mark -

@implementation Unit_Tests

- (void)testIdentity
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"identity");
    CATransform3D theManualTransform = CATransform3DIdentity;
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testScale
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testScaleShort
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"s(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testTranslate
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"translate(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeTranslation(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testTranslateShort
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"t(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeTranslation(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testRotate
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"rotate(10, 1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeRotation(10.0, 1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testRotateShort
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"r(10, 1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeRotation(10.0, 1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testConcat
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(10, 10, 10) | scale(2, 2, 2)");
    CATransform3D theManualTransform = CATransform3DScale(CATransform3DMakeScale(2, 2, 2), 10, 10, 10);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testFloats
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1.0, 100.1, -10.5)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1.0, 100.1, -10.5);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testIsEqual
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(0.0, 100.0, 10.0);
    XCTAssert(!CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

// TODO write more unit tests. For format strings and for inferred parameters. Also cached values.

#pragma mark -

static BOOL CATransform3DIsEqual(CATransform3D A, CATransform3D B)
    {
//    return memcmp(&A, &B, sizeof(A)) == 0;
    if (A.m11 != B.m11 || A.m12 != B.m12 || A.m13 != B.m13 || A.m14 != B.m14)
        {
        return(NO);
        }
    if (A.m21 != B.m21 || A.m22 != B.m22 || A.m23 != B.m23 || A.m24 != B.m24)
        {
        return(NO);
        }
    if (A.m31 != B.m31 || A.m32 != B.m32 || A.m33 != B.m33 || A.m34 != B.m34)
        {
        return(NO);
        }
    if (A.m41 != B.m41 || A.m42 != B.m42 || A.m43 != B.m43 || A.m44 != B.m44)
        {
        return(NO);
        }

    return(YES);
    }

@end
