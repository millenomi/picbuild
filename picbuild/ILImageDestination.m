//
//  ILImageDestination.m
//  picbuild
//
//  Created by ∞ on 01/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ILImageDestination.h"

@implementation ILImageDestination {
    CGImageDestinationRef destination;
}

+ (NSArray*) saveableTypeIdentifiers;
{
    return [NSMakeCollectable(CGImageDestinationCopyTypeIdentifiers()) autorelease];
}

+ (BOOL) supportsSavingWithType:(NSString*) type;
{
    for (NSString* saveable in [self saveableTypeIdentifiers]) {
        if (UTTypeConformsTo((CFStringRef) type, (CFStringRef) saveable))
            return YES;
    }
    
    return NO;
}

- (id) initWithCGImageDestination:(CGImageDestinationRef) d;
{
    self = [super init];
    if (self) {
        destination = (CGImageDestinationRef) CFMakeCollectable(CFRetain(d));
    }
    
    return self;
}

- (void)dealloc;
{
    CFRelease(destination);
    [super dealloc];
}

- (id) initWithType:(NSString*) type imagesCount:(size_t) count options:(NSDictionary*) options outputToMutableData:(NSMutableData*) data;
{
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((CFMutableDataRef) data, (CFStringRef) type, count, (CFDictionaryRef) options);
    self = [self initWithCGImageDestination:dest];
    CFRelease(dest);
    
    return self;
}

- (id) initWithType:(NSString*) type imagesCount:(size_t) count options:(NSDictionary*) options outputToURL:(NSURL*) url;
{
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef) url, (CFStringRef) type, count, (CFDictionaryRef) options);
    self = [self initWithCGImageDestination:dest];
    CFRelease(dest);
    
    return self;
}

- (void) addImage:(ILImage*) image options:(NSDictionary*) options;
{
    CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef) options);
}

- (void) addImageFromProvider:(id <ILImageProvider>) provider options:(NSDictionary*) options;
{
    CGImageDestinationAddImageFromSource(destination, provider.CGImageSource, provider.indexInCGImageSource, (CFDictionaryRef) options);
}

- (BOOL) save;
{
    return CGImageDestinationFinalize(destination)? YES : NO;
}

@end
