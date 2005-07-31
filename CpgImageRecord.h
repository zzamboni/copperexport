//
//  CpgImageRecord.h
//  FlickrExport
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

#import <Cocoa/Cocoa.h>
@class ExportMgr;

@interface CpgImageRecord : NSObject {
	NSString *filePath;
	NSMutableArray *tags;
	NSString *title;
	NSString *descriptionText;
	BOOL public;
	BOOL friendsAccess;
	BOOL familyAccess;
	BOOL landscape;
	int newWidth;
	int newHeight;
	NSData *thumbnailData;
	NSString *thumbnailPath;
	NSSize originalSize;
	NSDictionary *exif;
	NSString *imageFormat;
}

+ (id)recordFromExporter: (ExportMgr *)exportManager atIndex: (int)idx;
- (id)initWithImageManager: (ExportMgr *)exportManager index: (int)idx;

- (void)clearAllTags;

- (BOOL)metadataContainsString: (NSString *)searchTerm;

- (NSString *)filePath;
- (void)setFilePath:(NSString *)aFilePath;

- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;

- (NSString *)descriptionText;
- (void)setDescriptionText:(NSString *)aDescriptionText;

- (BOOL)public;
- (void)setPublic:(BOOL)flag;

- (BOOL)friendsAccess;
- (void)setFriendsAccess:(BOOL)flag;

- (BOOL)familyAccess;
- (void)setFamilyAccess:(BOOL)flag;

- (int)newWidth;
- (void)setNewWidth:(int)aNewWidth;

- (int)newHeight;
- (void)setNewHeight:(int)aNewHeight;

- (NSMutableArray *)tags;
- (void)setTags:(NSMutableArray *)aTags;

- (NSData *)thumbnailData;
- (void)setThumbnailData:(NSData *)aThumbnailData;

- (BOOL)landscape;
- (void)setLandscape:(BOOL)flag;

- (NSSize)originalSize;
- (void)setOriginalSize:(NSSize)anOriginalSize;

- (BOOL)needsResize;

- (NSDictionary *)exif;
- (void)setExif:(NSDictionary *)anExif;

- (NSString *)imageFormat;
- (void)setImageFormat:(NSString *)anImageFormat;

- (BOOL)isJpeg;
@end
