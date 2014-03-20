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
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"identity");
    CATransform3D theManualTransform = CATransform3DIdentity;
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testScale
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"scale(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testScaleShort
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"s(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testTranslate
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"translate(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeTranslation(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testTranslateShort
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"t(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeTranslation(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testRotate
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"rotate(10, 1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeRotation(10.0, 1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testRotateShort
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"r(10, 1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeRotation(10.0, 1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

- (void)testConcat
    {
    CATransform3D theDSLTransform = CATransform3DWithFormat(@"scale(10, 10, 10) | scale(2, 2, 2)");
    CATransform3D theManualTransform = CATransform3DScale(CATransform3DMakeScale(2, 2, 2), 10, 10, 10);
    XCTAssert(CATransform3DIsEqual(theDSLTransform, theManualTransform));
    }

// TODO write more unit tests. For format strings and for inferred parameters. Also cached values.

#pragma mark -

static BOOL CATransform3DIsEqual(CATransform3D A, CATransform3D B)
    {
    return memcmp(&A, &B, sizeof(A)) == 0;
    }

@end
