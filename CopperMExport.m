//
//  CopperMExport.m
//
// Copyright (c) 2005, Diego Zamboni
// Based on code by Fraser Speirs, original license shown below.
// Originally called FlickerExport.m
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

#import "CopperMExport.h"
#import "CpgImageRecord.h"
#import "CopperResponse.h"
#import "CpgKeyChain.h"

@implementation CopperMExport
- (id)description {
	return NSLocalizedString(@"Coppermine Export", @"Name of the Plugin");
}

- (id)name {
	return NSLocalizedString(@"Coppermine", @"Title of the tab, I think");
}

- (void)cancelExport {}

- (void)unlockProgress {}

- (void)lockProgress {}

- (void *)progress { return (void *)@""; }

- (void)performExport:(id)param {}

- (void)startExport:(id)param {
	[self savePreferences];
	
	NSString *un = [self username];
	NSString *pw = [self password];
	NSString *url = [self cpgurl];
	
	if((pw == nil || [pw length] == 0) ||
	   (un == nil || [un length] == 0) ||
	   (url == nil || [url length] == 0)) 
	{
		NSRunAlertPanel(NSLocalizedString(@"Missing Credentials", @"Title of Missing Credentials alert"),
						NSLocalizedString(@"You have not supplied a login, password and URL", @"Message telling the user that they have not supplied credentials"),
						NSLocalizedString(@"OK", @"OK"), nil,nil);
		
		[self showCredentialsSheet: self];
	}
	else {
		uploader = [[CopperUploader alloc] initWithUsername: un
												   password: pw
													    url: url
											   imageRecords: imageRecords];
		[uploader setDelegate: self];
		
		if (![uploader login]) {
			NSRunAlertPanel(NSLocalizedString(@"Could not log in", @"Title of Invalid Login alert"),
							NSLocalizedString(@"Could not log in. Make sure your login information is correct",
											  @"Message telling the user that we could not log in"),
							NSLocalizedString(@"OK", @"OK"), nil, nil);
			[self showCredentialsSheet: self];
			return;
		}
		
		if (![uploader getPublishInfo]) {
			return;
		}
		[self setAlbums:[uploader albums]];
		[self setSelectedAlbum:nil];
		if (albums && [albums count] > 0)
			[self setSelectedAlbum:[albums objectAtIndex:0]];
		else
			[self setSelectedAlbum:nil];
		[self setCategories:[uploader categories]];
		if (categories && [categories count] > 0)
			[self setSelectedCategory:[categories objectAtIndex:0]];
		else
			[self setSelectedCategory:nil];
		if (newAlbumName) {
			[newAlbumName release];
		}
		[self setNewAlbumName: nil];
		[self setNewAlbumNameIsEmpty: YES];
		[self setCanCreateAlbums: [uploader canCreateAlbums]];

		if (!([uploader areThereAlbums] || [uploader canCreateAlbums])) {
			NSRunAlertPanel(NSLocalizedString(@"You cannot upload pictures", @"Title of you cannot upload pictures alert"),
							NSLocalizedString(@"There are no albums where you can upload pictures, and you do not have permission to create new albums. "
											  "Please make sure your authentication information is correct, and that your account has the appropriate permissions.",
											  @"Message telling the user that he cannot upload pictures"),
							NSLocalizedString(@"OK", @"OK"), nil, nil);
			return;
		}
		
		if ([self showAlbumsSheet: self] == -1) {
			return;
		}
		
		// Here, we compute how many steps we're going to have in the progress bar.
		// 2 per image + 2 per resized image + 2 if we need to create an album.
		//
		// Then, we increment the bar each time we get one of the following calls:
		// willResize, didResize, willUpload, didUpload
		
		double progressSteps = (double)[[self imageRecords] count] * 2.0;
		NSEnumerator *en = [[self imageRecords] objectEnumerator];
		CpgImageRecord *anImage;
		while(anImage = [en nextObject]) {
			if([anImage needsResize]) {
				progressSteps += 2.0;
			}
		}
		if (![self newAlbumNameIsEmpty]) {
			progressSteps += 2.0;
		}

		[progBar setMaxValue: progressSteps];
		[progBar setMinValue: 0.0];
		[progBar setDoubleValue: 0.0];
		
		[NSApp beginSheet: progressSheet 
		   modalForWindow: [[self settingsView] window]
			modalDelegate: nil
		   didEndSelector: nil
			  contextInfo: nil];
		
		if (![self whichAlbum]) {
			return;
		}
		
//		NSLog(@"Selected album: %s", [[selectedAlbum stringValue] cString]);
		[uploader setSelectedAlbum: selectedAlbum];
//		NSLog(@"Selected category: %s", [[selectedCategory stringValue] cString]);
		[uploader setSelectedCategory: selectedCategory];
		
		if([exportManager imageCount] > 0) {
			[NSThread detachNewThreadSelector: @selector(beginUpload)
									 toTarget: uploader
								   withObject: nil];
		}
		else {
			NSRunAlertPanel(NSLocalizedString(@"No images selected", @"Title of alert telling user to select images"),
							NSLocalizedString(@"No images to export", @"Body of alert telling user to select images"),
							NSLocalizedString(@"OK", @"OK"), nil, nil);		
		}
	}
}

- (void)clickExport { }

- (BOOL)validateUserCreatedPath:(id)fp8 {
	return YES;
}

- (BOOL)treatSingleSelectionDifferently {
	return NO;
}

- (id)defaultDirectory {
	return NSHomeDirectory();
}

- (id)defaultFileName {
	return @"image.jpg";
}

- (id)getDestinationPath {
	return [NSString stringWithFormat: @"%@/img.jpg", NSHomeDirectory()];
}

- (BOOL)wantsDestinationPrompt {
	return NO;
}

- (id)requiredFileType {
	return @"jpg";
}

- (void)viewWillBeDeactivated {
	[self savePreferences];
}

- (void)viewWillBeActivated {
	prefs=[[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	
	if(prefs) {
		[self setUsername: [prefs objectForKey:@"username"]];
		[self setShouldOpenCopper: [[prefs objectForKey: @"shouldOpenCopper"] boolValue]];
		[self setCpgurl: [prefs objectForKey: @"cpgurl"]];
	}
	else {
		[self setShouldOpenCopper: YES];
	}
	
	albums = [NSMutableArray arrayWithCapacity:5];
	
	[self setCpgImageRecords: [NSMutableArray array]];
	int i;
	for(i = 0; i < [exportManager imageCount]; i++) {
		/*
		 * There's a question about whether we should do this loop in reverse.  Copper orders
		 * everything based on reverse-chronological upload time, so a large batch-upload 
		 * appears in reverse order from the way it is in iPhoto.
		 */
		[[self mutableArrayValueForKey: @"imageRecords"] addObject: [CpgImageRecord recordFromExporter: exportManager atIndex: i]];
	}
	
	[recordController setSelectionIndexes: [NSIndexSet indexSet]];
}

- (id)lastView {
	return lastView;
}

- (id)firstView {
	return firstView;
}

- (id)settingsView {
	return settingsBox;
}

- (id)initWithExportImageObj:(ExportMgr *)exportMgr {
	if(self = [super init]) {
		exportManager = exportMgr;
		[NSBundle loadNibNamed: @"ExportUI" owner:self];
	}
	
	return self;
}

// Uploader Delegate Methods
- (void)uploaderDidBeginProcess {
	[responses release];
	responses = [[NSMutableArray array] retain];
}

- (void)uploaderWillUploadImageAtIndex: (NSNumber *)idx {
	[progText setStringValue: [NSString stringWithFormat:@"Uploading %d of %d", [idx intValue]+1, [exportManager imageCount]]];
	[progBar incrementBy: 1.0];
	
}

- (void)uploaderDidUploadImageAtIndex: (NSNumber *)index {
	[progBar incrementBy: 1.0];
}

- (void)uploaderWillResizeImageAtIndex: (NSNumber *)idx {
	[progBar incrementBy: 1.0];
	[progText setStringValue: [NSString stringWithFormat:@"Resizing %d of %d", [idx intValue]+1, [exportManager imageCount]]];
}

- (void)uploaderDidResizeImageAtIndex: (NSNumber *)idx {
	[progBar incrementBy: 1.0];	
}

- (void)uploaderDidEndProcess {
	[progText setStringValue: @""];
	[progBar setDoubleValue: 0.0];

	if([imageRecords count] == 1) {
		[progBar stopAnimation: self];
	}
	
	if(shouldOpenCopper) {
		// Now open the redirection URL.
		NSMutableString *urlString = [NSMutableString stringWithCapacity: 100];
		[urlString appendString: [self cpgurl]];
		if ([urlString characterAtIndex:([urlString length]-1)] != '/')
			[urlString appendString:@"/"];
		[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:
			[NSString stringWithFormat:@"%sthumbnails.php?album=%d", [urlString cString], [selectedAlbum number]]]];
	}
	
	[NSApp endSheet: progressSheet];
	[progressSheet orderOut: self];
	
	[[exportManager exportController] cancel:self];
}

- (void)uploaderDidCancelProcess {
	[progText setStringValue: @""];
	[progBar setDoubleValue: 0.0];
	
	if([imageRecords count] == 1) {
		[progBar stopAnimation: self];
	}	
	[NSApp endSheet: progressSheet];
	[progressSheet orderOut: self];
}

- (void)uploaderReceivedResponse: (CopperResponse *)response {
//	NSLog(@"In uploaderReceivedResponse: status=%d, str=%s", [response status], [[response str] cString]);
	switch([response status]) {
		case CpgStatusOK:	// Nothing to do
			return;
		case CpgStatusError:  // Simple (user) error
			NSRunAlertPanel(NSLocalizedString(@"Error", @""),
							[response str],
							NSLocalizedString(@"OK", @"OK"), nil, nil);
			break;
		case CpgStatusCritError: // Bad (server) error
			NSRunAlertPanel(NSLocalizedString(@"Critical Error", @""),
							[NSString stringWithFormat:@"A server-side error occurred:\n%s", [[response str] cString]],
							NSLocalizedString(@"OK", @"OK"), nil, nil);
			break;
		case CpgStatusUnknown:   // who knows
			NSRunAlertPanel(NSLocalizedString(@"Unknown response", @""),
							[NSString stringWithFormat:@"The server sent a response I don't understand. Please report this to copperexport@zzamboni.org:\n%s", [[response str] cString]],
							NSLocalizedString(@"OK", @"OK"), nil, nil);
			break;			
	}
	[uploader cancelUpload];
}

- (void)controlTextDidChange: (NSNotification *)note {
	CpgImageRecord *imgRec = [[recordController selectedObjects] objectAtIndex: 0];
	
	id sender = [note object];
	if(sender == resizeWidth) {
		int oldWidth = [imgRec originalSize].width;
		int newWidth = [[sender stringValue] intValue];
			  
		float r = (float)newWidth/(float)oldWidth;
		int h = r * [imgRec originalSize].height;
			
		[imgRec setNewHeight: h];
	}
	else if(sender == resizeHeight) {
		int oldHeight = [imgRec originalSize].height;
		int newHeight = [[sender stringValue] intValue];
		
		float r = (float)newHeight/(float)oldHeight;
			
		int w = r * [imgRec originalSize].width;
			
		[imgRec setNewWidth: w];
	}
}

- (IBAction)applyCurrentScalingToAll:(id)sender {
	[[settingsBox window] endEditingFor: nil];
	CpgImageRecord *currentImage = [[recordController selectedObjects] objectAtIndex:0];
	BOOL currentDimensionsAreLandscape = [currentImage newWidth] > [currentImage newHeight];
	
	int shortSide, longSide;
	if(currentDimensionsAreLandscape) {
		shortSide = [currentImage newHeight];
		longSide = [currentImage newWidth];
	}
	else {
		shortSide = [currentImage newWidth];
		longSide = [currentImage newHeight];		
	}
	
	NSEnumerator *en = [[self imageRecords] objectEnumerator];
	CpgImageRecord *rec;
	
	while(rec = [en nextObject]) {
		if([rec newWidth] > [rec newHeight]) { // Is landscape
			[rec setNewWidth: longSide];
			[rec setNewHeight: shortSide];
		}
		else { // portrait
			[rec setNewWidth: shortSide];
			[rec setNewHeight: longSide];
		}
	}
}

- (IBAction)applyCurrentAccessToAll: (id)sender {
	[[settingsBox window] endEditingFor: nil];
	CpgImageRecord *currentImage = [[recordController selectedObjects] objectAtIndex:0];
	
	BOOL currentPublicSetting = [currentImage public];
	BOOL currentFriendsSetting = [currentImage friendsAccess];
	BOOL currentFamilySetting = [currentImage familyAccess];

	NSEnumerator *en = [[self imageRecords] objectEnumerator];
	CpgImageRecord *rec;
	
	while(rec = [en nextObject]) {
		[rec setFriendsAccess: currentFriendsSetting];
		[rec setFamilyAccess: currentFamilySetting];
		[rec setPublic: currentPublicSetting];
	}
}

- (IBAction)applyCurrentTagsToAll: (id)sender {
	[[settingsBox window] endEditingFor: nil];
	CpgImageRecord *currentImage = [[recordController selectedObjects] objectAtIndex:0];
	
	NSArray *selectedTags = [currentImage tags];
	
	NSEnumerator *en = [[self imageRecords] objectEnumerator];
	CpgImageRecord *rec;
	
	while(rec = [en nextObject]) {
		// Let's just be really careful not to alias any pointers here, OK?
		NSMutableArray *newTags = [NSMutableArray array];
		int i;
		for(i=0; i < [selectedTags count]; i++) {
			[newTags addObject: [[selectedTags objectAtIndex:i] copy]];
		}
		
		[rec setTags: newTags];
	}
}

- (IBAction)addSelectedTagToAll: (id)sender {
	[[settingsBox window] endEditingFor: nil];
	
	NSString *tag = [[tagController selectedObjects] objectAtIndex: 0];
	NSEnumerator *en = [[self imageRecords] objectEnumerator];
	CpgImageRecord *rec;
	
	while(rec = [en nextObject]) {
		NSMutableArray *recordTags = [rec tags];
		if(![recordTags containsObject: tag])
			[[rec mutableArrayValueForKey: @"tags"] addObject: [tag copy]];
	}
}

- (IBAction)removeAllTags: (id)sender {
	[[self imageRecords] makeObjectsPerformSelector: @selector(clearAllTags)];
}

- (IBAction)applyTitleToAll: (id)sender {
	CpgImageRecord *rec = [[recordController selectedObjects] objectAtIndex: 0];
	[[self imageRecords] makeObjectsPerformSelector: @selector(setTitle:)
										 withObject: [rec title]];
}

- (IBAction)applyDescriptionToAll: (id)sender {
	CpgImageRecord *rec = [[recordController selectedObjects] objectAtIndex: 0];
	[[self imageRecords] makeObjectsPerformSelector: @selector(setDescriptionText:)
										 withObject: [rec descriptionText]];
}

- (IBAction)cancelUpload: (id)sender {
	[uploader cancelUpload];
	[NSApp endSheet: progressSheet];
	[progressSheet orderOut: self];
}

// ===========================================================
// - imageRecords:
// ===========================================================
- (NSMutableArray *)imageRecords {
    return imageRecords; 
}

// ===========================================================
// - setCpgImageRecords:
// ===========================================================
- (void)setCpgImageRecords:(NSMutableArray *)anCpgImageRecords {
    if (imageRecords != anCpgImageRecords) {
        [anCpgImageRecords retain];
        [imageRecords release];
        imageRecords = anCpgImageRecords;
    }
}

	
// ===========================================================
// - username:
// ===========================================================
- (NSString *)username {
    return username; 
}

// ===========================================================
// - setUsername:
// ===========================================================
- (void)setUsername:(NSString *)anUsername {
    if (username != anUsername) {
        [anUsername retain];
        [username release];
        username = anUsername;
		
		[self setPassword: [self passwordForUsername: username]];
    }
}


// ===========================================================
// - password:
// ===========================================================
- (NSString *)password {
    return password; 
}

// ===========================================================
// - setPassword:
// ===========================================================
- (void)setPassword:(NSString *)aPassword {
    if (password != aPassword) {
        [aPassword retain];
        [password release];
        password = aPassword;
		[self savePasswordToKeychain];
    }
}

// ===========================================================
// - cpgurl:
// ===========================================================
- (NSString *)cpgurl {
    return cpgurl; 
}

// ===========================================================
// - setCpgurl:
// ===========================================================
- (void)setCpgurl:(NSString *)aCpgurl {
	if (cpgurl != aCpgurl) {
		NSMutableString *newurl = [NSMutableString stringWithCapacity: 100];
		// Add http:// by default if it's not there
		if ([aCpgurl rangeOfString:@"http://" options:(NSCaseInsensitiveSearch|NSAnchoredSearch)].location == NSNotFound &&
			[aCpgurl rangeOfString:@"https://" options:(NSCaseInsensitiveSearch|NSAnchoredSearch)].location == NSNotFound) {
			[newurl appendString:@"http://"];
		}
		NSRange rng=[aCpgurl rangeOfString:@"/index.php"];
		if (rng.location != NSNotFound)
			[newurl appendString:[aCpgurl substringToIndex:rng.location]];
		else
			[newurl appendString:[NSString stringWithString:aCpgurl]];
		if ([newurl characterAtIndex:([newurl length]-1)] != '/')
			[newurl appendString:@"/"];
		[newurl retain];
		[cpgurl release];
		cpgurl = newurl;
		//		NSLog([@"cpgurl = " stringByAppendingString:cpgurl]);
	}
}

// =========================================================== 
// - shouldOpenCopper:
// =========================================================== 
- (BOOL)shouldOpenCopper {
	
    return shouldOpenCopper;
}

// =========================================================== 
// - setShouldOpenCopper:
// =========================================================== 
- (void)setShouldOpenCopper:(BOOL)flag {
	shouldOpenCopper = flag;
}

- (void)savePreferences {
	[[settingsBox window] endEditingFor: nil];
	if([self username] != nil) {
		prefs = [[NSDictionary alloc] initWithObjects: [NSArray arrayWithObjects: [self username], [NSNumber numberWithBool: [self shouldOpenCopper]], [self cpgurl], nil]
											  forKeys: [NSArray arrayWithObjects: @"username", @"shouldOpenCopper", @"cpgurl", nil]];
		
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass: [self class]] bundleIdentifier]];
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
		
		[prefs release];
	}
}

- (NSString *)passwordForUsername: (NSString *)uname {
	NSString *serviceString = [NSString stringWithFormat: @"CopperExport: %@", uname];

	return [[CpgKeyChain defaultKeyChain] passwordForService: serviceString account: uname];
}

- (void) savePasswordToKeychain {
	NSString *serviceString = [NSString stringWithFormat: @"CopperExport: %@", [self username]];
	[[CpgKeyChain defaultKeyChain] setPassword: [self password]
								 forService: serviceString
									account: [self username]];
}

// Credentials
- (IBAction)showCredentialsSheet: (id)sender {
	if([self username])
		[usernameField setStringValue: [self username]];
	else 
		[usernameField setStringValue: @""];
	
	if([self password])
		[passwdField setStringValue: [self password]];
	else
		[passwdField  setStringValue: @""];
		
	if([self cpgurl])
		[cpgurlField setStringValue:[self cpgurl]];
	else
		[cpgurlField setStringValue:@""];
	
	[NSApp beginSheet: credentialsSheet
	   modalForWindow: [[self settingsView] window]
		modalDelegate: nil
	   didEndSelector: nil
		  contextInfo: nil];
}

- (IBAction)credentialsSheetCancel: (id)sender {
	// Close the sheet
	[self credentialsSheetOK: self];
	[self setUsername: [usernameField stringValue]];
	[self setPassword: [passwdField stringValue]];
	[self setCpgurl:   [cpgurlField stringValue]];
}

- (IBAction)credentialsSheetOK: (id)sender {
	[self setPassword:[passwdField stringValue]];
	[credentialsSheet endEditingFor: nil];
	[NSApp endSheet: credentialsSheet];
	[credentialsSheet orderOut: self];
}

// Album selection
- (int)showAlbumsSheet: (id)sender {
	return [NSApp runModalForWindow:albumsSheet];
}

- (IBAction)albumsSheetCancel: (id) sender {
	[albumsSheet orderOut:self];
	[self setSelectedAlbum:nil];
	[NSApp stopModalWithCode:-1];
}

- (IBAction)albumsSheetOK: (id) sender {
	[albumsSheet orderOut:self];
	[NSApp stopModalWithCode:0];
}

- (NSMutableArray *)albums {
	return albums;
}

- (void) setAlbums: (NSMutableArray *)newalbums {
	if (albums != newalbums) {
		albums = [[NSMutableArray alloc] initWithArray: newalbums];
	}
}

- (CopperAlbum *)selectedAlbum {
	if (selectedAlbum == nil) {
		if (albums && [albums count] > 0) {
			selectedAlbum = [albums objectAtIndex:0];
		}
	}
	return selectedAlbum;
}

- (void) setSelectedAlbum:(CopperAlbum *)newalbum {
	if (selectedAlbum != newalbum) {
		selectedAlbum = newalbum;
	}
}

- (NSArray *)categories {
	return categories;
}

- (void) setCategories: (NSArray *)newcategories {
	if (categories != newcategories) {
		categories = [[NSArray alloc] initWithArray: newcategories];
	}
}

- (CopperAlbum *)selectedCategory {
	if (selectedCategory == nil) {
		if (categories && [categories count] > 0) {
			selectedCategory = [categories objectAtIndex:0];
		}
	}
	return selectedCategory;
}

- (void) setSelectedCategory:(CopperAlbum *)newcategory {
	if (selectedCategory != newcategory) {
		selectedCategory = newcategory;
	}
}

- (NSString *)newAlbumName {
	return newAlbumName;
}

- (void) setNewAlbumName: (NSString *)albumname {
	if (newAlbumName != albumname) {
		newAlbumName = [albumname copy];
	}
	[self setNewAlbumNameIsEmpty:((newAlbumName == nil) || ([newAlbumName length] == 0))];
}

- (BOOL) whichAlbum {
	if (![self newAlbumNameIsEmpty]) {
		// If the user specified a new album name, create it, otherwise just use the album
		// that was selected in the popup list.
		CopperAlbum *newalbum;
		if (newAlbumName && [newAlbumName length] > 0) {
			[progText setStringValue: [NSString stringWithFormat:@"Creating album %s", [newAlbumName cString]]];
			[progBar incrementBy: 1.0];
			newalbum = [uploader createNewAlbum:newAlbumName inCategory:[selectedCategory number]];
			if (newalbum) {
				[progBar incrementBy: 1.0];
				[albums addObject:newalbum];
				[self setSelectedAlbum: newalbum];
			}
			else {
				NSRunAlertPanel(NSLocalizedString(@"Could not create album", @"Title of could not create album alert"),
								NSLocalizedString(@"You do not have permissions to create the album",
												  @"Message telling the user that we could not create the album"),
								NSLocalizedString(@"OK", @"OK"), nil, nil);
				return FALSE;
			}
		}	
	}
	[newAlbumName release];
	newAlbumName = nil;
	[albumsSheet makeKeyWindow];
	return TRUE;
}

- (BOOL) newAlbumNameIsEmpty {
//	NSLog(@"Returning newAlbumNameIsEmpty = %d", newAlbumNameIsEmpty);
	return newAlbumNameIsEmpty;
}

- (void) setNewAlbumNameIsEmpty: (BOOL)newvalue {
//	NSLog(@"Setting newAlbumNameIsEmpty to %d", newvalue);
	newAlbumNameIsEmpty = newvalue;
}

- (BOOL) canCreateAlbums {
	return canCreateAlbums;
}

- (void) setCanCreateAlbums: (BOOL)newvalue {
	canCreateAlbums = newvalue;
}

@end
