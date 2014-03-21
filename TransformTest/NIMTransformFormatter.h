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

+ (instancetype)formatterWithFormat:(NSString *)inFormat, ...;

- (instancetype)initWithFormat:(NSString *)inFormat, ...;
- (instancetype)initWithFormat:(NSString *)inFormat arguments:(va_list)argList;

- (CATransform3D)CATransform3D;
- (CATransform3D)CATransform3DWithBaseTransform:(CATransform3D)inBaseTransform;

- (CGAffineTransform)CGAffineTransform;

@end

extern CATransform3D CATransform3DMakeWithFormat(NSString *inFormat, ...);
extern CATransform3D CATransform3DWithFormat(CATransform3D inTransform, NSString *inFormat, ...);

extern NSString *const kNIMTransformDSLErrorDomain;
extern NSString *const kNIMTransformDSLParseException;
extern NSString *const kNIMTransformDSLNotAffineException;

