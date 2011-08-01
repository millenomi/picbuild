//
//  ILImage.h
//  picbuild
//
//  Created by ∞ on 01/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

typedef struct {
    size_t width;
    size_t height;
} ILImageIntegralSize;

static inline ILImageIntegralSize ILImageIntegralSizeMake(size_t width, size_t height) {
    return (ILImageIntegralSize) { .width = width, .height = height };
}

@interface ILImage : NSObject <NSCopying>

- (id) initWithSize:(ILImageIntegralSize) size attributesLikeImage:(ILImage*) i drawingOperations:(void(^)(CGContextRef)) drawing;

- (id) initWithCGImage:(CGImageRef) image;
- (id) initWithImageInBounds:(CGRect) bounds ofCGImage:(CGImageRef)i;

- (ILImage*) imageWithContentInRect:(CGRect) bounds;

- (void) drawWithinRect:(CGRect) rect ofContext:(CGContextRef) context;

@property(readonly, nonatomic) CGSize size;
@property(readonly, nonatomic) ILImageIntegralSize integralSize;

@property(readonly, nonatomic) CGImageRef CGImage;

@end
