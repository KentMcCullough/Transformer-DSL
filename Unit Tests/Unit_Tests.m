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
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testScale
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testScaleShort
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"s(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testTranslate
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"translate(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeTranslation(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testTranslateShort
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"t(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeTranslation(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testRotate
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"rotate(10, 1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeRotation(10.0, 1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testRotateShort
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"r(10, 1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeRotation(10.0, 1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testConcat
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(10, 10, 10) | scale(2, 2, 2)");
    CATransform3D theManualTransform = CATransform3DScale(CATransform3DMakeScale(2, 2, 2), 10, 10, 10);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testFloats
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1.0, 100.1, -10.5)");
    CATransform3D theManualTransform = CATransform3DMakeScale(1.0, 100.1, -10.5);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testIsEqual
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1000, 100, 10)");
    CATransform3D theManualTransform = CATransform3DMakeScale(0.0, 100.0, 10.0);
    XCTAssert(!CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testRelativeScale
    {
    CATransform3D theBaseTransform = CATransform3DMakeScale(100, 100, 100);
    CATransform3D theDSLTransform = CATransform3DWithFormat(theBaseTransform, @"scale(10, 10, 10)");
    CATransform3D theManualTransform = CATransform3DScale(theBaseTransform, 10, 10, 10);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testFormat1
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1000, 100, %f)", 10.0);
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

- (void)testFormat2
    {
    CATransform3D theDSLTransform = CATransform3DMakeWithFormat(@"scale(1000, %f, %f)", 100.0, 10.0);
    CATransform3D theManualTransform = CATransform3DMakeScale(1000.0, 100.0, 10.0);
    XCTAssert(CATransform3DEqualToTransform(theDSLTransform, theManualTransform));
    }

// TODO write more unit tests. For format strings and for inferred parameters. Also cached values.

@end
