//
//  NIMTransformFormatter.h
//  TransformTest
//
//  Created by Jonathan Wight on 3/6/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>

@interface NIMTransformFormatter : NSObject

//+ (instancetype)formatterWithFormat:(NSString *)inFormat;

- (instancetype)initWithFormat:(NSString *)inFormat, ...;
- (instancetype)initWithFormat:(NSString *)inFormat arguments:(va_list)argList;

- (CATransform3D)CATransform3D;
- (NSValue *)CATransform3DValue;

@end

extern CATransform3D CATransform3DWithStringFormat(NSString *inFormat, ...);
extern NSValue *CATransform3DValueWithStringFormat(NSString *inFormat, ...);