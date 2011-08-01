//
//  main.m
//  picbuild
//
//  Created by ∞ on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PicbuildProject.h"
#import "ILImageSource.h"
#import "ILImageDestination.h"

#define ILError(x, ...) do { \
    fprintf(stderr, "error: " x "\n", ## __VA_ARGS__); \
    exit(1); \
} while(0)

#define ILWarning(x, ...) do { \
    fprintf(stderr, "warning: " x "\n", ## __VA_ARGS__); \
} while(0)

static ILImage* PicbuildAppropriateImageForFactory(NSArray* sourceImages, PicbuildImageFactory* factory) {
    if ([sourceImages count] == 0)
        ILError("No source images found.");
    
    ILImageIntegralSize size = (ILImageIntegralSize) {
        .width = [factory.width unsignedLongValue],
        .height = [factory.height unsignedLongValue],
    };
    
    return [[sourceImages sortedArrayUsingComparator:^NSComparisonResult (ILImage* a, ILImage* b) {
        ILImageIntegralSize
            imageSizeA = a.integralSize,
            imageSizeB = b.integralSize;
        
        // shortcut
        if (imageSizeA.width == imageSizeB.width &&
            imageSizeA.height == imageSizeB.height)
            return NSOrderedSame;
        
        ssize_t deltaWidthA = imageSizeA.width - size.width, deltaHeightA = imageSizeA.height - size.height;
        ssize_t deltaWidthB = imageSizeB.width - size.width, deltaHeightB = imageSizeB.height - size.height;
        
        BOOL isAPositive = (deltaWidthA > 0 && deltaHeightA > 0);
        BOOL isBPositive = (deltaWidthB > 0 && deltaHeightB > 0);
        
        if (isAPositive && !isBPositive)
            return NSOrderedDescending;
        if (!isAPositive && isBPositive)
            return NSOrderedAscending;
        
        ssize_t comparisonA = MIN(ABS(deltaWidthA), ABS(deltaHeightA)),
            comparisonB = MIN(ABS(deltaWidthB), ABS(deltaHeightB));
        if (comparisonA < comparisonB)
            return NSOrderedDescending;
        else if (comparisonB < comparisonA)
            return NSOrderedAscending;
        else
            return NSOrderedSame;

    }] lastObject];
}

int main (int argc, const char * argv[])
{
    if (argc != 3) {
        ILError("You must specify two arguments. Usage: %s <picbuild bundle> <output directory>", argv[0]);
        return 1;
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];

    // ----- check out paths
    
    NSString* projectPath = [fm stringWithFileSystemRepresentation:argv[1] length:strlen(argv[1])];
    NSString* bundlePath = [projectPath stringByDeletingLastPathComponent];
    NSString* outputPath = [fm stringWithFileSystemRepresentation:argv[2] length:strlen(argv[2])];
    BOOL isDir;
    BOOL exists = [fm fileExistsAtPath:outputPath isDirectory:&isDir];
    if (!exists || !isDir)
        ILError("Could not find specified output path %s", [outputPath fileSystemRepresentation]);
    
    exists = [fm fileExistsAtPath:bundlePath isDirectory:&isDir];
    if (!exists || !isDir)
        ILError("Could not find specified picbuild bundle at path %s", [bundlePath fileSystemRepresentation]);
    
    bundlePath = [bundlePath stringByStandardizingPath];
    outputPath = [outputPath stringByStandardizingPath];

    // ----- pick up the project

    NSDictionary* projectPlist = [NSDictionary dictionaryWithContentsOfFile:projectPath];
    if (!projectPlist)
        ILError("Could not read the picbuild project from path %s", [projectPath fileSystemRepresentation]);
    
    NSError* err;
    PicbuildProject* project = [[PicbuildProject alloc] initWithValue:projectPlist error:&err];
    if (!project)
        ILError("Could not load the project due to this error:\n%s", [[err description] UTF8String]);
    
    // ----- load all source images
    
    NSMutableArray* sourceImages = [NSMutableArray new];
    
    NSArray* content = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:bundlePath] includingPropertiesForKeys:[NSArray array] options:0 error:&err];
    if (!content)
        ILError("Could not read the contents of the source bundle %s due to error:\n%s", [bundlePath fileSystemRepresentation], [[err description] UTF8String]);
    
    for (NSURL* item in content) {
        if ([[item pathExtension] isEqualToString:@"picbuild"])
            continue;
        
        NSString* type = [ILImageSource loadableTypeIdentifierForURL:item];
        if (!type)
            continue;
        
        NSDictionary* opts = [NSDictionary dictionaryWithObjectsAndKeys:
                              type, (id) kCGImageSourceTypeIdentifierHint,
                              nil];
        
        ILImageSource* source = [[ILImageSource alloc] initWithContentsOfURL:item options:opts];
        if (source.available) {
            
            for (id <ILImageProvider> provider in source.imageProviders) {
                [sourceImages addObject:[provider imageWithOptions:[NSDictionary dictionary]]];
            }
            
        } else {
            ILError("Could not load potential source image at path %s due to error:\n%s", [[item path] UTF8String], [[source.error description] UTF8String]);
        }
    }
    
    // ----- build each factory
    
    NSString* baseName = project.imageBaseName;
    if (!baseName)
        baseName = [bundlePath lastPathComponent];
    if (![[baseName pathExtension] isEqualToString:@""])
        baseName = [baseName stringByDeletingPathExtension];
    
    for (PicbuildImageFactory* factory in project.imageFactories) {
        NSString* name = [factory nameByExpandingPlaceholderWithBaseName:baseName];
        NSString* path = [outputPath stringByAppendingPathComponent:name];
        
        ILImage* source = PicbuildAppropriateImageForFactory(sourceImages, factory);
        
        ILImageIntegralSize size = ILImageIntegralSizeMake([factory.width unsignedLongValue], [factory.height unsignedLongValue]);
        
        ILImage* edited = [[ILImage alloc] initWithSize:size attributesLikeImage:source drawingOperations:^(CGContextRef context) {
            
            [source drawWithinRect:CGRectMake(0, 0, size.width, size.height) ofContext:context];
            
        }];
        
        NSString* type = [factory deducedTypeAfterExpandingPlaceholderWithBaseName:baseName];
        if (![ILImageDestination supportsSavingWithType:type])
            ILError("Cannot deduce the correct type for file %s, or the type is not supported by Core Graphics. Tried type %s.", [path fileSystemRepresentation], [type UTF8String]);
        
        ILImageDestination* dest = [[ILImageDestination alloc] initWithType:type imagesCount:1 options:[NSDictionary dictionary] outputToURL:[NSURL fileURLWithPath:path]];
        
        [dest addImage:edited options:[NSDictionary dictionary]];
        if (![dest save])
            ILError("Could not save edited image produced by factory with name %s", [name UTF8String]);
    }
    
    return 0;
}

