//
//  ILImageSource.m
//  picbuild
//
//  Created by ∞ on 01/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ILImageSource.h"
#import <CoreServices/CoreServices.h>

@interface ILImageSourceContainedProvider : NSObject <ILImageProvider>
- (id) initWithCGImageSource:(CGImageSourceRef) source index:(size_t) index;
@end

@implementation ILImageSource {
    CGImageSourceRef source;
    NSArray* providers;
}

+ (NSArray*) loadableTypeIdentifiers;
{
    return [NSMakeCollectable(CGImageSourceCopyTypeIdentifiers()) autorelease];
}

+ (NSString *)loadableTypeIdentifierForURL:(NSURL *)url;
{
    NSString* extension = [[[url filePathURL] path] pathExtension];
    CFStringRef typeRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) extension, kUTTypeItem);
    
    NSString* type = [NSMakeCollectable(typeRef) autorelease];
    
    for (NSString* imageType in [self loadableTypeIdentifiers]) {
        if (UTTypeConformsTo((CFStringRef) type, (CFStringRef) imageType))
            return imageType;
    }
    
    return nil;
}

@synthesize CGImageSource = source;

- (id) initWithCGImageSource:(CGImageSourceRef) s;
{
    self = [super init];
    if (self) {
        source = (CGImageSourceRef) CFMakeCollectable(CFRetain(s));
    }
    
    return self;
}

- (void)dealloc;
{
    [providers release];
    CFRelease(source);
    
    [super dealloc];
}

- (id) initWithDataProvider:(CGDataProviderRef) provider options:(NSDictionary*) options;
{
    CGImageSourceRef s = CGImageSourceCreateWithDataProvider(provider, (CFDictionaryRef) options);
    self = [self initWithCGImageSource:s];
    CFRelease(s);
    
    return self;
}

- (id) initWithData:(NSData*) data options:(NSDictionary*) options;
{
    CGImageSourceRef s = CGImageSourceCreateWithData((CFDataRef) data, (CFDictionaryRef) options);
    self = [self initWithCGImageSource:s];
    CFRelease(s);
    
    return self;
}

- (id) initWithContentsOfURL:(NSURL*) url options:(NSDictionary*) options;
{
    CGImageSourceRef s = CGImageSourceCreateWithURL((CFURLRef) url, (CFDictionaryRef) options);
    self = [self initWithCGImageSource:s];
    CFRelease(s);
    
    return self;
}

- (id) initIncrementalWithOptions:(NSDictionary*) options;
{
    CGImageSourceRef s = CGImageSourceCreateIncremental((CFDictionaryRef) options);
    self = [self initWithCGImageSource:s];
    CFRelease(s);
    
    return self;
}

- (void) appendData:(NSData*) data final:(BOOL) final;
{
    CGImageSourceUpdateData(source, (CFDataRef) data, final? true : false);
}

- (void) setNextDataProvider:(CGDataProviderRef) provider final:(BOOL) final;
{
    CGImageSourceUpdateDataProvider(source, provider, final? true : false);
}

- (BOOL)finishedReading;
{
    return CGImageSourceGetStatus(source) != kCGImageStatusIncomplete;
}

- (BOOL)available;
{
    return CGImageSourceGetStatus(source) == kCGImageStatusComplete;
}

- (NSError*) error;
{
    CGImageSourceStatus status = CGImageSourceGetStatus(source);

    if (status == kCGImageStatusComplete || status == kCGImageStatusIncomplete)
        return nil;
    
    return [NSError errorWithDomain:@"net.infinite-labs.ILImageSource.CGImageSourceStatus" code:status userInfo:nil];
}

- (NSDictionary *)properties;
{
    return [self propertiesWithOptions:[NSDictionary dictionary]];
}

- (NSDictionary*) propertiesWithOptions:(NSDictionary*) options;
{
    return (NSDictionary*) CGImageSourceCopyProperties(source, (CFDictionaryRef) options);
}

- (NSArray *)imageProviders;
{
    if (!self.available)
        return nil;
    
    if (!providers) {
        size_t count = CGImageSourceGetCount(source);
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:count];
        
        for (size_t i = 0; i < count; i++) {
            ILImageSourceContainedProvider* provider = [[[ILImageSourceContainedProvider alloc] initWithCGImageSource:source index:i] autorelease];
            [arr addObject:provider];
        }
        
        providers = [arr copy];
    }
    
    return providers;
}

@end

@implementation ILImageSourceContainedProvider {
    CGImageSourceRef source;
    size_t index;
}

- (id)initWithCGImageSource:(CGImageSourceRef) s index:(size_t) i;
{
    self = [super init];
    if (self) {
        source = (CGImageSourceRef) CFMakeCollectable(CFRetain(s));
        index = i;
    }
    return self;
}

- (BOOL)finishedReading;
{
    return CGImageSourceGetStatusAtIndex(source, index) != kCGImageStatusIncomplete;
}

- (BOOL)available;
{
    return CGImageSourceGetStatusAtIndex(source, index) == kCGImageStatusComplete;
}

- (NSError*) error;
{
    CGImageSourceStatus status = CGImageSourceGetStatusAtIndex(source, index);
    
    if (status == kCGImageStatusComplete || status == kCGImageStatusIncomplete)
        return nil;
    
    return [NSError errorWithDomain:@"net.infinite-labs.ILImageSource.CGImageSourceStatus" code:status userInfo:nil];
}

- (NSDictionary *)properties;
{
    return [self propertiesWithOptions:[NSDictionary dictionary]];
}

- (NSDictionary*) propertiesWithOptions:(NSDictionary*) options;
{
    return (NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, index, (CFDictionaryRef) options);
}

- (ILImage *)imageWithOptions:(NSDictionary *)options;
{
    CGImageRef CGImage = CGImageSourceCreateImageAtIndex(source, index, (CFDictionaryRef) options);
    ILImage* image = nil;
    
    if (CGImage) {
        image = [[[ILImage alloc] initWithCGImage:CGImage] autorelease];
        CFRelease(CGImage);
    }
    
    return image;
}

- (ILImage *)thumbnailImageWithOptions:(NSDictionary *)options;
{
    CGImageRef CGImage = CGImageSourceCreateThumbnailAtIndex(source, index, (CFDictionaryRef) options);
    ILImage* image = nil;
    
    if (CGImage) {
        image = [[[ILImage alloc] initWithCGImage:CGImage] autorelease];
        CFRelease(CGImage);
    }
    
    return image;
}

@synthesize CGImageSource = source, indexInCGImageSource = index;

@end

