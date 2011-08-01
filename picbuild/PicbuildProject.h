//
//  PicbuildProject.h
//  picbuild
//
//  Created by ∞ on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Foundation/Basics/ILSchema.h"

@interface PicbuildProject : ILSchema

@property(readonly, nonatomic) NSNumber* version;

@property(readonly, nonatomic) NSString* imageBaseName;
@property(readonly, nonatomic) NSArray* imageFactories;

@end

// ---------------------------------

@interface PicbuildImageFactory : ILSchema

@property(readonly, nonatomic) NSNumber* width, * height;
// @property(readonly, nonatomic) NSNumber* scale;
@property(readonly, nonatomic) NSString* name;

- (NSString*) nameByExpandingPlaceholderWithBaseName:(NSString*) name;

@property(readonly, nonatomic) NSString* type; // a UTI

- (NSString *)deducedTypeAfterExpandingPlaceholderWithBaseName:(NSString*) name;

@end