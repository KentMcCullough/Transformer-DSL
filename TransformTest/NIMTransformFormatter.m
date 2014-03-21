//
//  NIMTransformFormatter.m
//  TransformTest
//
//  Created by Jonathan Wight on 3/6/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import "NIMTransformFormatter.h"

#import <QuartzCore/QuartzCore.h>

NSString *const kNIMTransformDSLErrorDomain = @"kNIMTransformDSLErrorDomain";
NSString *const kNIMTransformDSLParseException = @"kNIMTransformDSLParseException";
NSString *const kNIMTransformDSLNotAffineException = @"kNIMTransformDSLNotAffineException";

@interface NIMTransformFormatter ()
@property (readwrite, nonatomic, copy) NSString *format;
@property (readwrite, nonatomic, copy) NSArray *arguments;
@end

#pragma mark -

@implementation NIMTransformFormatter

+ (NSCache *)_transformsCache
    {
    static NSCache *gCache = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gCache = [[NSCache alloc] init];
        gCache.countLimit = 512; // abitrary but relatively small.
        });
    return gCache;
    }

+ (NSCache *)_operationsCache
    {
    static NSCache *gCache = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gCache = [[NSCache alloc] init];
        gCache.countLimit = 512; // abitrary but relatively small.
        });
    return gCache;
    }


+ (instancetype)formatterWithFormat:(NSString *)inFormat, ...
    {
    va_list argList;
    va_start(argList, inFormat);
    NIMTransformFormatter *theFormatter = [(NIMTransformFormatter *)[self alloc] initWithFormat:inFormat arguments:argList];
    va_end(argList);
    return theFormatter;
    }

- (instancetype)initWithFormat:(NSString *)inFormat, ...
    {
    va_list argList;
    va_start(argList, inFormat);
    self = [self initWithFormat:inFormat arguments:argList];
    va_end(argList);
    return self;
    }

- (instancetype)initWithFormat:(NSString *)inFormat arguments:(va_list)argList
    {
    if ((self = [super init]) != NULL)
        {
        _format = [inFormat copy];

        NSMutableArray *theArguments = [NSMutableArray array];
        NSRange theSearchRange = { 0, [inFormat length] };
        NSRange theFoundRange;
        do
            {
            theFoundRange = [inFormat rangeOfString:@"%f" options:0 range:theSearchRange];
            NSUInteger theEnd = theFoundRange.location + theFoundRange.length;
            theSearchRange = (NSRange){ .location = theEnd, .length = [inFormat length] - theEnd };

            if (theFoundRange.location != NSNotFound)
                {
                CGFloat theArgument = va_arg(argList, CGFloat);
                [theArguments addObject:@(theArgument)];
                }
            }
        while (theFoundRange.location != NSNotFound);

        _arguments = [theArguments copy];
        }
    return self;
    }

- (CATransform3D)CATransform3D
    {
    return [self CATransform3DWithBaseTransform:CATransform3DIdentity];
    }

- (CATransform3D)CATransform3DWithBaseTransform:(CATransform3D)inBaseTransform
    {
    NSValue *theValue = [[NIMTransformFormatter _transformsCache] objectForKey:self.format];
    if (theValue != NULL)
        {
        return [theValue CATransform3DValue];
        }

    CATransform3D theTransform = inBaseTransform;
    NSError *theError = NULL;
    if ([self _transform:&theTransform error:&theError] == NO)
        {
        [[NSException exceptionWithName:kNIMTransformDSLParseException reason:@"Failed to parse format string" userInfo:NULL] raise];
        }

    if (self.arguments.count == 0)
        {
        [[NIMTransformFormatter _transformsCache] setObject:[NSValue valueWithCATransform3D:theTransform] forKey:self.format];
        }

    return theTransform;
    }

- (CGAffineTransform)CGAffineTransform
    {
    CATransform3D theTransform = [self CATransform3D];
    if (!CATransform3DIsAffine(theTransform))
        {
        [[NSException exceptionWithName:kNIMTransformDSLNotAffineException reason:@"Cannot convert non-afine transformation to an affine one." userInfo:NULL] raise];
        }
    return CATransform3DGetAffineTransform(theTransform);
    }

#pragma mark -

- (BOOL)_transform:(CATransform3D *)ioTransform error:(NSError **)outError
    {
    CATransform3D theTransform = *ioTransform;

    NSArray *theFunctions = [[NIMTransformFormatter _operationsCache] objectForKey:self.format];
    if (theFunctions == NULL)
        {
        NSScanner *theScanner = [NSScanner scannerWithString:self.format];
        [self scanner:theScanner scanFunctions:&theFunctions];
        [[NIMTransformFormatter _operationsCache] setObject:theFunctions forKey:self.format];
        }

    __block NSUInteger nextArgument = 0;
    CGFloat (^GetNextArgument)(id inParameter) = ^(id inParameter) {
        if ([inParameter isKindOfClass:[NSNumber class]] == YES)
            {
            return([inParameter doubleValue]);
            }
        else if (nextArgument < self.arguments.count)
            {
            return([self.arguments[nextArgument++] doubleValue]);
            }
        else
            {
            NSParameterAssert(0);
            return(0.0);
            }
        };

    for (NSDictionary *theFunction in theFunctions)
        {
        NSString *theName = theFunction[@"name"];
        NSArray *theParameters = theFunction[@"parameters"];

        if ([theName isEqualToString:@"translate"] || [theName isEqualToString:@"t"])
            {
            theTransform = CATransform3DTranslate(theTransform,
                theParameters.count >= 1 ? GetNextArgument(theParameters[0]) : 0.0,
                theParameters.count >= 2 ? GetNextArgument(theParameters[1]) : 0.0,
                theParameters.count >= 3 ? GetNextArgument(theParameters[2]) : 0.0
                );
            }
        else if ([theName isEqualToString:@"scale"] | [theName isEqualToString:@"s"])
            {
            theTransform = CATransform3DScale(theTransform,
                theParameters.count >= 1 ? GetNextArgument(theParameters[0]) : 1.0,
                theParameters.count >= 2 ? GetNextArgument(theParameters[1]) : 1.0,
                theParameters.count >= 3 ? GetNextArgument(theParameters[2]) : 1.0
                );
            }
        else if ([theName isEqualToString:@"rotate"] | [theName isEqualToString:@"r"])
            {
            theTransform = CATransform3DRotate(theTransform,
                GetNextArgument(theParameters[0]),
                GetNextArgument(theParameters[1]),
                GetNextArgument(theParameters[2]),
                GetNextArgument(theParameters[3])
                );
            }
        else if ([theName isEqualToString:@"identity"] | [theName isEqualToString:@"i"])
            {
            // Nothing to do here. Identity is essentially a nop.
            }
        else
            {
            if (outError)
                {
                *outError = [NSError errorWithDomain:kNIMTransformDSLErrorDomain code:-1 userInfo:NULL];
                }
            return NO;
            }
        }

    if (ioTransform)
        {
        *ioTransform = theTransform;
        }

    return YES;
    }

#pragma mark -

- (BOOL)scanner:(NSScanner *)inScanner scanFunctions:(NSArray **)outFunctions
    {
    NSMutableArray *theFunctions = [NSMutableArray array];
    while ([inScanner isAtEnd] == NO)
        {
        NSDictionary *theFunction = NULL;
        if ([self scanner:inScanner scanFunction:&theFunction] == YES)
            {
            [theFunctions addObject:theFunction];
            }
        else if ([inScanner scanString:@"|" intoString:NULL] == NO)
            {
            break;
            }
        }

    if (outFunctions != NULL)
        {
        *outFunctions = theFunctions;
        }

    return YES;
    }

- (BOOL)scanner:(NSScanner *)inScanner scanFunction:(NSDictionary **)outFunction
    {
    NSUInteger theSavedLocation = inScanner.scanLocation;

    NSString *theName = NULL;
    if ([inScanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&theName] == NO)
        {
        inScanner.scanLocation = theSavedLocation;
        return NO;
        }

    if ([inScanner scanString:@"(" intoString:NULL] == NO)
        {
        inScanner.scanLocation = theSavedLocation;
        return NO;
        }

    NSArray *theArray = NULL;
    if ([self scanner:inScanner scanArrayOfParameters:&theArray] == NO)
        {
        inScanner.scanLocation = theSavedLocation;
        return NO;
        }

    if ([inScanner scanString:@")" intoString:NULL] == NO)
        {
        inScanner.scanLocation = theSavedLocation;
        return NO;
        }

    if (outFunction != NULL)
        {
        *outFunction = @{ @"name": theName, @"parameters": theArray };
        }

    return YES;
    }

- (BOOL)scanner:(NSScanner *)inScanner scanArrayOfParameters:(NSArray **)outNumbers
    {
    BOOL theResult = NO;

    NSMutableArray *theArray = [NSMutableArray array];

    NSUInteger theSavedLocation = inScanner.scanLocation;

    while (inScanner.isAtEnd == NO)
        {
        double theDouble;
        if ([inScanner scanDouble:&theDouble] == YES)
            {
            [theArray addObject:@(theDouble)];
            }
        else if ([inScanner scanString:@"%f" intoString:NULL] == YES)
            {
            [theArray addObject:@"%f"];
            }
        else
            {
            break;
            }

        if ([inScanner scanString:@"," intoString:NULL] == NO)
            {
            theResult = YES;
            break;
            }
        }

    if (theResult == NO)
        {
        inScanner.scanLocation = theSavedLocation;
        }

    if (theResult == YES && outNumbers != NULL)
        {
        *outNumbers = theArray;
        }

    return theResult;
    }

@end

CATransform3D CATransform3DMakeWithFormat(NSString *inFormat, ...)
    {
    va_list argList;
    va_start(argList, inFormat);
    NIMTransformFormatter *theFormatter = [[NIMTransformFormatter alloc] initWithFormat:inFormat arguments:argList];
    va_end(argList);
    return([theFormatter CATransform3D]);
    }

CATransform3D CATransform3DWithFormat(CATransform3D inTransform, NSString *inFormat, ...)
    {
    va_list argList;
    va_start(argList, inFormat);
    NIMTransformFormatter *theFormatter = [[NIMTransformFormatter alloc] initWithFormat:inFormat arguments:argList];
    va_end(argList);
    return([theFormatter CATransform3DWithBaseTransform:inTransform]);
    }