// Originally called ImageRecord.m
//
//  CpgImageRecord.m
//  CopperExport
//
// Copyright (c) 2004, Fraser Speirs
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
//     * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// 
//     * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
// 
//     * Neither the name of Fraser Speirs nor the names of its contributors may be
// used to endorse or promote products derived from this software without specific
// prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "CpgImageRecord.h"
#import "ExportMgr.h"

@interface CpgImageRecord (Private)
- (void)populateExif;
@end

@implementation CpgImageRecord

+ (id)recordFromExporter: (ExportMgr *)exportManager atIndex: (int)idx {
	CpgImageRecord *rec = [[CpgImageRecord alloc] initWithImageManager: exportManager index: idx];

	return [rec autorelease];
}

- (id)initWithImageManager: (ExportMgr *)exportManager index: (int)idx {
	self = [super init];
	if(self) {
		NSDictionary *iPhotoMetadata = [exportManager imageDictionaryAtIndex: idx];
		
		if([exportManager imagePathAtIndex: idx])
			[self setFilePath: [exportManager imagePathAtIndex: idx]];
		else {
			NSLog(@"No image path for image %d", idx);
		}

		[self populateExif];
		
		if([iPhotoMetadata objectForKey:@"Annotation"])
			[self setDescriptionText: [iPhotoMetadata objectForKey:@"Annotation"]];
		else
			[self setDescriptionText: @""];
		
		NSString *caption = [iPhotoMetadata objectForKey:@"Caption"];
		if(caption)
			[self setTitle: caption];
		else 
			[self setTitle: [NSString stringWithFormat: @"Image %d", idx]];
		
		[self setPublic: YES];
		[self setFamilyAccess: NO];
		[self setFriendsAccess: NO];
		
		[self setLandscape: ![exportManager imageIsPortraitAtIndex:idx]];
		
	// Image Size
		NSSize imageSize = [exportManager imageSizeAtIndex: idx];
		[self setOriginalSize: imageSize];
		[self setNewWidth: imageSize.width];
		[self setNewHeight: imageSize.height];
		
	// Thumbnail Data
		NSString *thumbPath = [exportManager thumbnailPathAtIndex: idx];
		if(thumbPath) {
			NSData *data = [NSData dataWithContentsOfFile: thumbPath];
			NSSize thumbSize = [self landscape] ? NSMakeSize(200.0,150.0) : NSMakeSize(112.5, 150.0);
				// Do some jiggery-pokery
			NSImage *thumb = [[NSImage alloc] initWithData: data];
			[thumb setScalesWhenResized: YES];
			NSImage *sizedThumb = [[NSImage alloc] initWithSize: thumbSize];
			
			[sizedThumb lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[thumb setSize: thumbSize];
			[thumb compositeToPoint: NSZeroPoint operation: NSCompositeCopy];
			[sizedThumb unlockFocus];
			
			[self setThumbnailData: [sizedThumb TIFFRepresentation]];
			
			[thumb release];
			[sizedThumb release];
			
		} else {
			[self setThumbnailData: nil];
		}
		
		[self setTags: [NSMutableArray array]];
		NSArray *iPhotoKeywords = [iPhotoMetadata objectForKey: @"KeyWords"];
		int i;
		for(i = 0; i < [iPhotoKeywords count]; i++) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject: [[iPhotoKeywords objectAtIndex:i] stringValue] forKey: @"content"];
			[[self mutableArrayValueForKey: @"tags"] addObject: dict];
		}
	}
	return self;
}

- (void)clearAllTags {
	[self setTags: [NSMutableArray array]];
}

- (BOOL)metadataContainsString: (NSString *)searchTerm {
	NSString *term = [searchTerm lowercaseString];
	if([self public] && [term isEqualToString: @"public"])
		return YES;
	
	if(![self public] && [term isEqualToString: @"private"])
		return YES;
	
	if([self friendsAccess] && [term isEqualToString: @"friends"])
		return YES;
	
	if([self familyAccess] && [term isEqualToString: @"family"])
		return YES;
	
	if([self title] && [[[self title] lowercaseString] rangeOfString: term].location != NSNotFound)
		return YES;
	
	if([self descriptionText] && [[[self descriptionText] lowercaseString] rangeOfString: term].location != NSNotFound)
		return YES;
	
	NSEnumerator *tagEnum = [[self tags] objectEnumerator];
	NSDictionary *aTag;
	while(aTag = [tagEnum nextObject]) {
		if([[[aTag objectForKey: @"content"] lowercaseString] rangeOfString: term].location != NSNotFound)
			return YES;
	}
	
	NSString *make = [[[self exif] objectForKey: @"make"] lowercaseString];
	NSString *model = [[[self exif] objectForKey: @"model"] lowercaseString];

	if(make && [make rangeOfString: term].location != NSNotFound)
		return YES;
	
	if(model && [model rangeOfString: term].location != NSNotFound)
		return YES;
		
	return NO;	
}

// ===========================================================
// - filePath:
// ===========================================================
- (NSString *)filePath {
    return filePath; 
}

// ===========================================================
// - setFilePath:
// ===========================================================
- (void)setFilePath:(NSString *)aFilePath {
    if (filePath != aFilePath) {
        [aFilePath retain];
        [filePath release];
        filePath = aFilePath;
    }
}

// ===========================================================
// - title:
// ===========================================================
- (NSString *)title {
	if(title != nil)
		return title; 
	else
		return @"";
}

// ===========================================================
// - setTitle:
// ===========================================================
- (void)setTitle:(NSString *)aTitle {
    if (title != aTitle) {
        [aTitle retain];
        [title release];
        title = aTitle;
    }
}


// ===========================================================
// - descriptionText:
// ===========================================================
- (NSString *)descriptionText {
    return descriptionText; 
}

// ===========================================================
// - setDescriptionText:
// ===========================================================
- (void)setDescriptionText:(NSString *)aDescriptionText {
    if (descriptionText != aDescriptionText) {
        [aDescriptionText retain];
        [descriptionText release];
        descriptionText = aDescriptionText;
    }
}

// ===========================================================
// - public:
// ===========================================================
- (BOOL)public {
	
    return public;
}

// ===========================================================
// - setPublic:
// ===========================================================
- (void)setPublic:(BOOL)flag {
	public = flag;
	if(public) {
		[self setFamilyAccess: NO];
		[self setFriendsAccess: NO];
	}
}

// ===========================================================
// - friendsAccess:
// ===========================================================
- (BOOL)friendsAccess {
    return friendsAccess;
}

// ===========================================================
// - setFriendsAccess:
// ===========================================================
- (void)setFriendsAccess:(BOOL)flag {
	friendsAccess = flag;
}

// ===========================================================
// - familyAccess:
// ===========================================================
- (BOOL)familyAccess {
    return familyAccess;
}

// ===========================================================
// - setFamilyAccess:
// ===========================================================
- (void)setFamilyAccess:(BOOL)flag {
	familyAccess = flag;
}


// ===========================================================
// - newWidth:
// ===========================================================
- (int)newWidth {
	
    return newWidth;
}

// ===========================================================
// - setNewWidth:
// ===========================================================
- (void)setNewWidth:(int)aNewWidth {
	newWidth = aNewWidth;
}

// ===========================================================
// - newHeight:
// ===========================================================
- (int)newHeight {
	
    return newHeight;
}

// ===========================================================
// - setNewHeight:
// ===========================================================
- (void)setNewHeight:(int)aNewHeight {
	newHeight = aNewHeight;
}

// ===========================================================
// - tags:
// ===========================================================
- (NSMutableArray *)tags {
    return tags; 
}

// ===========================================================
// - setTags:
// ===========================================================
- (void)setTags:(NSMutableArray *)aTags {
    if (tags != aTags) {
        [aTags retain];
        [tags release];
        tags = aTags;
    }
}


// ===========================================================
// - thumbnailData:
// ===========================================================
- (NSData *)thumbnailData {
    return thumbnailData; 
}

// ===========================================================
// - setThumbnailData:
// ===========================================================
- (void)setThumbnailData:(NSData *)aThumbnailData {
    if (thumbnailData != aThumbnailData) {
        [aThumbnailData retain];
        [thumbnailData release];
        thumbnailData = aThumbnailData;
    }
}

// ===========================================================
// - landscape:
// ===========================================================
- (BOOL)landscape {
	
    return landscape;
}

// ===========================================================
// - setLandscape:
// ===========================================================
- (void)setLandscape:(BOOL)flag {
	landscape = flag;
}


// ===========================================================
// - originalSize:
// ===========================================================
- (NSSize)originalSize {
	
    return originalSize;
}

// ===========================================================
// - setOriginalSize:
// ===========================================================
- (void)setOriginalSize:(NSSize)anOriginalSize {
	originalSize = anOriginalSize;
}

- (BOOL)needsResize {
	return !NSEqualSizes([self originalSize], NSMakeSize([self newWidth], [self newHeight]));
}

//=========================================================== 
//  exif 
//=========================================================== 
- (NSDictionary *)exif {
    return exif; 
}
- (void)setExif:(NSDictionary *)anExif {
    [anExif retain];
    [exif release];
    exif = anExif;
}
@end

@implementation CpgImageRecord (Private)
- (void)populateExif {
	NSString *path = [self filePath];
	if(path) {
		NSTask *sips = [[NSTask alloc] init];
		[sips setLaunchPath: @"/usr/bin/sips"];
		[sips setArguments: [NSArray arrayWithObjects: @"-g", @"allxml", path, nil]];
		
		NSPipe *outPipe = [[NSPipe pipe] retain];
		NSFileHandle *outFileHandle = [outPipe fileHandleForReading];
		
		[sips setStandardOutput: outPipe];
		
		[sips launch];
		[sips waitUntilExit];
		
		NSData *outData = [outFileHandle readDataToEndOfFile];
		NSString *plistString = [[NSString alloc] initWithData: outData encoding: NSUTF8StringEncoding];
		
		[exif release];
		[self setExif: [plistString propertyList]];
		[plistString release];
		[outPipe release];
		[sips release];
	}
}
@end