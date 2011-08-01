//
//  PicbuildProject.m
//  picbuild
//
//  Created by ∞ on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PicbuildProject.h"

#define ILSchemaScalarKey(name, Name, valueClass) \
    @dynamic name; \
    - validClassFor ## Name ## Key { return [valueClass class]; }

#define ILSchemaOptionalScalarKey(name, Name, valueClass) \
    ILSchemaScalarKey(name, Name, valueClass) \
    - (BOOL) isValueOptionalFor ## Name ## Key { return YES; }

#define ILSchemaArrayKey(name, Name, valueClass) \
    @dynamic name; \
    - validClassForValuesOf ## Name ## ArrayKey { return [valueClass class]; }

@implementation PicbuildProject

ILSchemaScalarKey(version, Version, NSNumber)
ILSchemaOptionalScalarKey(imageBaseName, ImageBaseName, NSString)
ILSchemaArrayKey(imageFactories, ImageFactories, PicbuildImageFactory)

- (BOOL)validateAndReturnError:(NSError **)e;
{
    if (![self.version isEqualToNumber:[NSNumber numberWithInt:0]]) {
        if (e) {
            NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"This version of picbuild only supports version number '0' in its Build.plist files.", NSLocalizedDescriptionKey,
                                  nil];
            
            *e = [NSError errorWithDomain:@"net.infinite-labs.picbuild" code:(NSInteger)'NEW!' userInfo:info];
        }
        
        return NO;
    }
    
    return YES;
}

@end

@implementation PicbuildImageFactory

ILSchemaOptionalScalarKey(width, Width, NSNumber)
ILSchemaOptionalScalarKey(height, Height, NSNumber)

ILSchemaScalarKey(name, Name, NSString)

ILSchemaOptionalScalarKey(type, Type, NSString)

- (NSString*) nameByExpandingPlaceholderWithBaseName:(NSString*) name;
{
    return [self.name stringByReplacingOccurrencesOfString:@"{BASE_NAME}" withString:name options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.name length])];
}

- (NSString *)deducedTypeAfterExpandingPlaceholderWithBaseName:(NSString*) name;
{
    if (self.type)
        return self.type;

    NSString* fullName = [self nameByExpandingPlaceholderWithBaseName:name];
    
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef) [fullName pathExtension], kUTTypeItem);
    
    return [NSMakeCollectable(type) autorelease];
}

@end
