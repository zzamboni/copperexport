//
//  CopperMExport.h
//
// Copyright (c) 2005, Diego Zamboni
// Based on code by Fraser Speirs, original license shown below.
// Originally called FlickerExport.h
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
#import "ExportPluginProtocol.h"
#import "ExportMgr.h"
#import "FUCopperBox.h"
#import "CopperAlbum.h"

#import "CopperUploader.h"

@interface CopperMExport : NSObject <ExportPluginProtocol, CopperUploaderDelegate> {

	IBOutlet id firstView;
	IBOutlet id lastView;

	IBOutlet NSTextField *resizeWidth;
	IBOutlet NSTextField *resizeHeight;
		
//	IBOutlet NSMatrix *accessRadio;
//	IBOutlet NSButton *familyChk, *friendsChk;
		
	IBOutlet FUCopperBox *settingsBox;
	
	// Progress
	IBOutlet NSProgressIndicator *progBar;
	IBOutlet NSTextField *progText;
	
	ExportMgr *exportManager;
	CopperUploader *uploader;

	NSMutableArray *imageRecords;
	IBOutlet NSArrayController *recordController;
	IBOutlet NSArrayController *tagController;
	
	NSDictionary *prefs;

		
	NSMutableArray *responses;
	
	BOOL shouldOpenCopper;
	
	// Upload Sheet
	IBOutlet NSWindow *progressSheet;
	
	// Credentials Sheet
	IBOutlet NSWindow *credentialsSheet;
	// Albums Sheet
	IBOutlet NSWindow *albumsSheet;
	
	// Credentials
	NSString *username;
	NSString *password;
	NSString *cpgurl;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSSecureTextField *passwdField;
	IBOutlet NSTextField *cpgurlField;

	// Image View
	IBOutlet NSImageView *imageView;
	
	// List of albums
	NSMutableArray *albums;
	// Selected album
	CopperAlbum *selectedAlbum;
	
	// List of categories
	NSArray *categories;
	// Selected category
	CopperAlbum *selectedCategory;
	
	// New album name and description
	NSString *newAlbumName;
	NSString *newAlbumDesc;
	BOOL newAlbumNameIsEmpty;
	BOOL canCreateAlbums;

	// CopperExport version
	NSString *version;
}

- (id)initWithExportImageObj:(ExportMgr *)exportMgr;

- (NSMutableArray *)imageRecords;
- (void)setCpgImageRecords:(NSMutableArray *)anCpgImageRecords;

- (BOOL)shouldOpenCopper;
- (void)setShouldOpenCopper:(BOOL)flag;

- (NSString *)username;
- (void)setUsername:(NSString *)anUsername;
- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;
- (NSString *)cpgurl;
- (void)setCpgurl:(NSString *)aCpgurl;

- (void)savePreferences;
- (NSString *)passwordForUsername: (NSString *)username;
- (void) savePasswordToKeychain;

- (IBAction)applyCurrentScalingToAll:(id)sender;
- (IBAction)applyCurrentAccessToAll: (id)sender;
- (IBAction)applyCurrentTagsToAll: (id)sender;
- (IBAction)addSelectedTagToAll: (id)sender;
- (IBAction)removeAllTags: (id)sender;
- (IBAction)applyTitleToAll: (id)sender;
- (IBAction)applyDescriptionToAll: (id)sender;

- (IBAction)cancelUpload: (id)sender;

// Credentials
- (IBAction)showCredentialsSheet: (id)sender;
- (IBAction)credentialsSheetCancel: (id)sender;
- (IBAction)credentialsSheetOK: (id)sender;

// Albums
- (int)showAlbumsSheet: (id)sender;
- (IBAction)albumsSheetCancel: (id) sender;
- (IBAction)albumsSheetOK: (id) sender;

- (NSMutableArray *)albums;
- (void) setAlbums: (NSArray *)newalbums;
- (CopperAlbum *)selectedAlbum;
- (void) setSelectedAlbum:(CopperAlbum *)newalbum;

// Categories
- (NSArray *)categories;
- (void) setCategories: (NSArray *)newcategories;
- (CopperAlbum *)selectedCategory;
- (void) setSelectedCategory:(CopperAlbum *)newcategory;

- (NSString *)newAlbumName;
- (void) setNewAlbumName: (NSString *)albumname;
- (NSString *)newAlbumDesc;
- (void) setNewAlbumDesc: (NSString *)albumdesc;

- (BOOL) newAlbumNameIsEmpty;
- (void) setNewAlbumNameIsEmpty: (BOOL)newvalue;
- (BOOL) whichAlbum;
- (BOOL) canCreateAlbums;
- (void) setCanCreateAlbums: (BOOL)newvalue;

- (NSString *)version;
- (void)setVersion: (NSString *)newversion;
- (NSString *)versionString;

@end
