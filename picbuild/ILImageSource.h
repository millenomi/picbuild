//
//  ILImageSource.h
//  picbuild
//
//  Created by ∞ on 01/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

#import "ILImage.h"

@interface ILImageSource : NSObject

+ (NSArray*) loadableTypeIdentifiers;
+ (NSString*) loadableTypeIdentifierForURL:(NSURL*) url;

- (id) initWithCGImageSource:(CGImageSourceRef) source;

- (id) initWithDataProvider:(CGDataProviderRef) provider options:(NSDictionary*) options;
- (id) initWithData:(NSData*) data options:(NSDictionary*) options;
- (id) initWithContentsOfURL:(NSURL*) url options:(NSDictionary*) options;

- (id) initIncrementalWithOptions:(NSDictionary*) options;
- (void) appendData:(NSData*) data final:(BOOL) final;
- (void) setNextDataProvider:(CGDataProviderRef) provider final:(BOOL) final;

@property(readonly, nonatomic) BOOL finishedReading;
@property(readonly, nonatomic) BOOL available;
@property(readonly, nonatomic) NSError* error;

@property(readonly, nonatomic) NSDictionary* properties;
- (NSDictionary*) propertiesWithOptions:(NSDictionary*) options;

- (NSArray*) imageProviders;

@property(readonly, nonatomic) CGImageSourceRef CGImageSource;

@end

@protocol ILImageProvider <NSObject>

@property(readonly, nonatomic) BOOL finishedReading;
@property(readonly, nonatomic) BOOL available;
@property(readonly, nonatomic) NSError* error;

@property(readonly, nonatomic) NSDictionary* properties;
- (NSDictionary*) propertiesWithOptions:(NSDictionary*) options;

- (ILImage*) imageWithOptions:(NSDictionary*) opts;
- (ILImage*) thumbnailImageWithOptions:(NSDictionary*) opts;

@property(readonly, nonatomic) CGImageSourceRef CGImageSource;
@property(readonly, nonatomic) size_t indexInCGImageSource;

@end
