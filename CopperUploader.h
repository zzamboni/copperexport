//
//  CopperUploader.h
//
// Copyright (c) 2005, Diego Zamboni
// Based on code by Fraser Speirs, original license shown below.
// Originally called FlickrUploader.h
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
#import "ExportMgr.h"
#import "CopperResponse.h"
#import "CopperAlbum.h"

@class CopperUploader;

@protocol CopperUploaderDelegate
- (void)uploaderDidBeginProcess;
- (void)uploaderWillResizeImageAtIndex: (NSNumber *)idx;
- (void)uploaderDidResizeImageAtIndex: (NSNumber *)idx;
- (void)uploaderWillUploadImageAtIndex: (NSNumber *)idx;
- (void)uploaderReceivedResponse: (CopperResponse *)response;
- (void)uploaderDidUploadImageAtIndex: (NSNumber *)idx;
- (void)uploaderDidEndProcess;
- (void)uploaderDidCancelProcess;
@end

@interface CopperUploader : NSObject {
	id <CopperUploaderDelegate> delegate;
	
	NSString *username;
	NSString *password;
	NSString *cpgurl;
	
	NSString *formBoundary;
	
	int cursor;	
	NSArray *imageRecords;
	BOOL uploadShouldCancel;
	
	NSMutableArray *albums;
	CopperAlbum *selectedAlbum;
	BOOL areThereAlbums;
	BOOL canCreateAlbums;
	BOOL canChooseCategory;
	NSMutableArray *categories;
	CopperAlbum *selectedCategory;
}

- (id)initWithUsername: (NSString *)name password: (NSString *)passwd url: (NSString *)url imageRecords: (NSArray *)recs;

- (BOOL)login;

- (void)beginUpload;
- (void)cancelUpload;
	
- (BOOL)getPublishInfo;
- (NSMutableArray *)listOfAlbums;

- (CopperAlbum *)createNewAlbum: (NSString *)albumName inCategory: (int)catnumber;

// ===========================================================
// Accessors
// ===========================================================
- (NSString *)username;
- (void)setUsername:(NSString *)anUsername;

- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;

- (NSString *)cpgurl;
- (void)setCpgurl:(NSString *)aCpgurl;

- (id <CopperUploaderDelegate>)delegate;
- (void)setDelegate:(id <CopperUploaderDelegate>)aDelegate;

- (NSMutableArray *)albums;
//- (void) setAlbums: (NSArray *)newalbums;
- (CopperAlbum *)selectedAlbum;
- (void) setSelectedAlbum:(CopperAlbum *)newalbum;

- (NSArray *)categories;
	//- (void) setCategories: (NSArray *)newcategories;
- (CopperAlbum *)selectedCategory;
- (void) setSelectedCategory:(CopperAlbum *)newcat;

- (BOOL) canCreateAlbums;
- (void) setCanCreateAlbums: (BOOL)newvalue;
- (BOOL) areThereAlbums;
- (void) setAreThereAlbums: (BOOL)newvalue;

@end
