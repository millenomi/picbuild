//
//  ILImageDestination.h
//  picbuild
//
//  Created by ∞ on 01/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

#import "ILImage.h"
#import "ILImageSource.h"

@interface ILImageDestination : NSObject

+ (NSArray*) saveableTypeIdentifiers;
+ (BOOL) supportsSavingWithType:(NSString*) type;

- (id) initWithCGImageDestination:(CGImageDestinationRef) d;

- (id) initWithType:(NSString*) type imagesCount:(size_t) count options:(NSDictionary*) options outputToMutableData:(NSMutableData*) data;
- (id) initWithType:(NSString*) type imagesCount:(size_t) count options:(NSDictionary*) options outputToURL:(NSURL*) url;

- (void) addImage:(ILImage*) image options:(NSDictionary*) options;
- (void) addImageFromProvider:(id <ILImageProvider>) provider options:(NSDictionary*) options;

- (BOOL) save;

@end
