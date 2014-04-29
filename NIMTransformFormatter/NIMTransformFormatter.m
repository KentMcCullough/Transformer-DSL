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
@property (readonly, nonatomic, copy) NSString *format;
@property (readonly, nonatomic, strong) NSArray *arguments;
@property (readonly, nonatomic, strong) NSArray *operations;
@end

#pragma mark -

@implementation NIMTransformFormatter

@synthesize operations = _operations;

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
    NSParameterAssert(inFormat != NULL);

    va_list argList;
    va_start(argList, inFormat);
    self = [self initWithFormat:inFormat arguments:argList];
    va_end(argList);
    return self;
    }

- (instancetype)initWithFormat:(NSString *)inFormat arguments:(va_list)argList
    {
    NSParameterAssert(inFormat != NULL);

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
                CGFloat theArgument = va_arg(argList, double);
                [theArguments addObject:@(theArgument)];
                }
            }
        while (theFoundRange.location != NSNotFound);

        _arguments = theArguments;
        }
    return self;
    }

- (NSArray *)operations
    {
    if (_operations == NULL)
        {
        NSParameterAssert(self.format != NULL);

        NSArray *theOperations = [[NIMTransformFormatter _operationsCache] objectForKey:self.format];
        if (theOperations == NULL)
            {
            NSScanner *theScanner = [NSScanner scannerWithString:self.format];
            [self _scanner:theScanner scanFunctions:&theOperations];
            [[NIMTransformFormatter _operationsCache] setObject:theOperations forKey:self.format];
            }
        _operations = theOperations;
        }
    return(_operations);
    }

- (CATransform3D)CATransform3D
    {
    return [self CATransform3DWithBaseTransform:CATransform3DIdentity];
    }

- (CATransform3D)CATransform3DWithBaseTransform:(CATransform3D)inBaseTransform
    {
    NSValue *theTransformValue = [[NIMTransformFormatter _transformsCache] objectForKey:self.format];
    if (theTransformValue != NULL)
        {
        return [theTransformValue CATransform3DValue];
        }

    CATransform3D theTransform = inBaseTransform;
    NSError *theError = NULL;
    if ([self _transform:&theTransform error:&theError] == NO)
        {
        [[NSException exceptionWithName:kNIMTransformDSLParseException reason:@"Failed to parse format string" userInfo:NULL] raise];
        }

    // We only cache if we have zero arguments. We obviously can't cache dynamic formats.
    if (self.arguments.count == 0)
        {
        [[NIMTransformFormatter _transformsCache] setObject:[NSValue valueWithCATransform3D:theTransform] forKey:self.format];
        }

    return theTransform;
    }

- (CGAffineTransform)CGAffineTransform
    {
    return [self CGAffineTransformWithBaseTransform:CGAffineTransformIdentity];
    }

- (CGAffineTransform)CGAffineTransformWithBaseTransform:(CGAffineTransform)inBaseTransform
    {
    CATransform3D theBaseTransform = CATransform3DMakeAffineTransform(inBaseTransform);
    CATransform3D theTransform = [self CATransform3DWithBaseTransform:theBaseTransform];
    if (!CATransform3DIsAffine(theTransform))
        {
        [[NSException exceptionWithName:kNIMTransformDSLNotAffineException reason:@"Cannot convert non-afine transformation to an affine one." userInfo:NULL] raise];
        }
    return CATransform3DGetAffineTransform(theTransform);
    }

#pragma mark -

- (BOOL)_transform:(CATransform3D *)ioTransform error:(NSError **)outError
    {
    NSParameterAssert(ioTransform != NULL);
    NSParameterAssert(self.operations != NULL);

    __block NSUInteger nextArgument = 0;
    CGFloat (^GetNextArgument)(id inParameter) = ^(id inParameter) {
        if ([inParameter isKindOfClass:[NSNumber class]] == YES)
            {
            return((CGFloat)[inParameter doubleValue]);
            }
        else if (nextArgument < self.arguments.count)
            {
            return((CGFloat)[self.arguments[nextArgument++] doubleValue]);
            }
        else
            {
            NSParameterAssert(0);
            return((CGFloat)0.0);
            }
        };

    CATransform3D theTransform = *ioTransform;

    for (NSDictionary *theOperation in self.operations)
        {
        NSString *theName = theOperation[@"name"];
        NSArray *theParameters = theOperation[@"parameters"];

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

- (BOOL)_scanner:(NSScanner *)inScanner scanFunctions:(NSArray **)outFunctions
    {
    NSParameterAssert(inScanner != NULL);

    NSMutableArray *theFunctions = [NSMutableArray array];
    while ([inScanner isAtEnd] == NO)
        {
        NSDictionary *theFunction = NULL;
        if ([self _scanner:inScanner scanFunction:&theFunction] == YES)
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

- (BOOL)_scanner:(NSScanner *)inScanner scanFunction:(NSDictionary **)outFunction
    {
    NSParameterAssert(inScanner != NULL);

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
    if ([self _scanner:inScanner scanArrayOfParameters:&theArray] == NO)
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

- (BOOL)_scanner:(NSScanner *)inScanner scanArrayOfParameters:(NSArray **)outNumbers
    {
    NSParameterAssert(inScanner != NULL);

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