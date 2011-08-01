//
//  ILImage.m
//  picbuild
//
//  Created by ∞ on 01/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ILImage.h"

@implementation ILImage {
    CGImageRef image;
}

- (id)initWithCGImage:(CGImageRef) i;
{
    self = [super init];
    if (self) {
        image = (CGImageRef) CFMakeCollectable(CFRetain(i));
    }
    
    return self;
}

@synthesize CGImage = image;

- (void)dealloc {
    CFRelease(image);
    [super dealloc];
}

- (id) initWithSize:(ILImageIntegralSize) size attributesLikeImage:(ILImage*) i drawingOperations:(void(^)(CGContextRef)) drawing;
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    if (!rgb)
        goto fail;
    
    const size_t bitsPerComponent = 8;
    size_t bytesPerRow = size.width * bitsPerComponent * (CGColorSpaceGetNumberOfComponents(rgb) + 1 /* alpha */);
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, bitsPerComponent, bytesPerRow, rgb, kCGImageAlphaPremultipliedLast);
    if (!context)
        goto fail;
    
    drawing(context);
    
    CGImageRef CGImage = CGBitmapContextCreateImage(context);
    if (!CGImage)
        goto fail;
    
success:
    self = [self initWithCGImage:CGImage];
    goto done;
    
fail:
    [self release]; self = nil;
    goto done;
    
done:
    if (rgb) CFRelease(rgb);
    if (context) CFRelease(context);
    if (CGImage) CFRelease(CGImage);
    
    return self;
}

- (id) initWithImageInBounds:(CGRect) bounds ofCGImage:(CGImageRef)i;
{
    CGImageRef newImage = CGImageCreateWithImageInRect(i, bounds);
    self = [self initWithCGImage:newImage];
    CFRelease(newImage);
    
    return self;
}

- (ILImage*) imageWithContentInRect:(CGRect) bounds;
{
    return [[[[self class] alloc] initWithImageInBounds:bounds ofCGImage:image] autorelease];
}

- (CGSize) size;
{
    return CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
}

- (ILImageIntegralSize) integralSize;
{
    return (ILImageIntegralSize) { .width = CGImageGetWidth(image), .height = CGImageGetHeight(image) };
}

- (void) drawWithinRect:(CGRect) rect ofContext:(CGContextRef) context;
{
    CGContextDrawImage(context, rect, image);
}

- (id)copyWithZone:(NSZone *)zone;
{
    CGImageRef newImage = CGImageCreateCopy(image);
    id x = [[[self class] allocWithZone:zone] initWithCGImage:newImage];
    CFRelease(newImage);

    return x;
}

@end
