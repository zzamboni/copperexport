//
//  CopperUploader.m
//
// Copyright (c) 2005, Diego Zamboni
// Based on code by Fraser Speirs, original license shown below.
// Originally called FlickrUploader.m
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

#import "CopperUploader.h"
#import "CpgImageRecord.h"
#import "CopperAlbum.h"

@interface CopperUploader (PrivateAPI)
- (void)uploadNextImage;
- (NSData *)generateFormData: (NSDictionary *)dict;

- (void)scaleFile: (NSString *)file toMaxSize: (int)maxLength;
- (NSString *)postForm: (NSMutableDictionary *)post_dict toURL: (NSString *)urlstr error: (NSError **)error;
- (NSString *)urlplus: (NSString *)suffix;
- (void)postError: (NSError *)error;
- (void)postResponse: (CopperResponse *)resp;
@end

@implementation CopperUploader

- (id)initWithUsername: (NSString *)name password: (NSString *)passwd url: (NSString *)url imageRecords: (NSArray *)recs {
	self = [super init];
	if(self) {
		[self setUsername: name];
		[self setPassword: passwd];
		[self setCpgurl: url];
		formBoundary = [[[NSProcessInfo processInfo] globallyUniqueString] retain];
		imageRecords = recs;
	}
	return self;
}

/* 
The idea here is that we kick off the first image upload, and set our cursor to 0.
 When that one's done, the connectionDidFinishLoading (or didFailWithError) calls 
 -uploadNextImage if any more remain.
 */
 
- (void)beginUpload {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderDidBeginProcess)
												  withObject: nil 
											   waitUntilDone: YES];
	int i;
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	NSAssert([imageRecords count] > 0, @"No images to upload");
	
	uploadShouldCancel = NO;
	//for(cursor = 0; !uploadShouldCancel && cursor < [imageRecords count]; cursor++) {
	// Want to do this in reverse in order to subvert Copper's reverse-chronological display
	cursor = 0;
	for(; !uploadShouldCancel && cursor < [imageRecords count]; cursor++) {
		[self uploadNextImage];
	}
	if(uploadShouldCancel) {
		[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderDidCancelProcess)
													  withObject: nil 
												   waitUntilDone: YES];
	}
	else {
		[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderDidEndProcess)
													  withObject: nil 
												   waitUntilDone: YES];
	}
	[pool release];
}

- (void)cancelUpload {
	uploadShouldCancel = YES;
}

// ===========================================================
// - delegate:
// ===========================================================
- (id <CopperUploaderDelegate>)delegate {
    return delegate; 
}

// ===========================================================
// - setDelegate:
// ===========================================================
- (void)setDelegate:(id <CopperUploaderDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
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
        [aCpgurl retain];
        [cpgurl release];
        cpgurl = aCpgurl;
    }
}

// ===========================================================
// - login:
// ===========================================================
- (BOOL)login {
	NSMutableDictionary *post_dict = [[NSMutableDictionary alloc] initWithCapacity: 2];
	NSError *error;
	[post_dict setValue:username		forKey:@"username"];
	[post_dict setValue:password		forKey:@"password"];
	
	NSString *resultstr = [self postForm:post_dict 
								   toURL:[self urlplus:@"xp_publish.php?cmd=login&lang=english"]
								   error:&error];
	if (!resultstr) {
		[self postError: error];
		return FALSE;
	}
	
	if ([resultstr rangeOfString:@"Couldn't log in"].location != NSNotFound) {
		NSLog(@"Could not log in.\n");
		return FALSE;
	}
	else {
		return TRUE;
	}	
}

// Get the list of albums and categories to which I can upload from the server.
- (BOOL)getPublishInfo {
	NSMutableDictionary *post_dict = [[NSMutableDictionary alloc] initWithCapacity:2];
	NSError *error;
	
	// Get the "publish" form, which includes the possible albums.
	NSString *resultstr = [self postForm:post_dict 
								   toURL:[self urlplus:@"xp_publish.php?cmd=publish&lang=english"]
								   error:&error];
	if (!resultstr) {
		[self postError: error];
		return FALSE;
	}
//	NSLog(@"Response string for publish information: %s", [resultstr cString]);
	
	if (albums) {
		[albums removeAllObjects];
		[albums release];
	}
	if (categories) {
		[categories removeAllObjects];
		[categories release];
	}
	albums = [NSMutableArray arrayWithCapacity:5];
	categories = [NSMutableArray arrayWithCapacity:5];
	[self setSelectedAlbum:nil];
	[self setSelectedCategory:nil];
	
	// Get existing albums if there are any
	areThereAlbums = NO;
	if ([resultstr rangeOfString:@"BEGIN existing_albums"].location != NSNotFound) {
		NSScanner *scan = [NSScanner scannerWithString:resultstr];
		NSString *tmpstr;
		if ([scan scanUpToString:@"<select id=\"album\"" intoString:NULL] &&
			[scan scanUpToString:@"</select>" intoString:&tmpstr]) {
			//		NSLog([@"Albums: " stringByAppendingString:tmpstr]);
			int albumid;
			NSString *albumname;
			// Now parse the select list
			scan = [NSScanner scannerWithString:tmpstr];
			if ([scan scanUpToString:@"<option" intoString:NULL]) {
				while ([scan scanString:@"<option value=\"" intoString:NULL] == YES) {
					if ([scan scanInt:&albumid] &&
						[scan scanString:@"\">" intoString:NULL] &&
						[scan scanUpToString:@"</option>" intoString:&albumname] &&
						[scan scanString:@"</option>" intoString:NULL]) {
						CopperAlbum *newalbum = [[CopperAlbum alloc] initWithName:[albumname copy] number:albumid];
						//			NSLog(@"Found album: %s", [[newalbum stringValue] cString]);
						[albums addObject:newalbum];
						areThereAlbums = YES;
					}
					else
						NSLog(@"Error: unable to parse string: %@", tmpstr);
				}
			}
			else
				NSLog(@"Error: unable to parse string: %@", tmpstr);
		}
		else
			NSLog(@"Error: unable to parse string: %@", resultstr);
	}
	else {
		NSLog(@"Could not find albums in response");
	}
	// Can I create new albums?
	if ([resultstr rangeOfString:@"BEGIN create_album"].location != NSNotFound) {
		canCreateAlbums = YES;
//		NSLog(@"User can create albums");
	}
	else {
		canCreateAlbums = NO;
//		NSLog(@"User cannot create albums");
	}
	// Get list of categories
	canChooseCategory = NO;
	if ([resultstr rangeOfString:@"BEGIN select_category"].location != NSNotFound) {
		NSScanner *scan = [NSScanner scannerWithString:resultstr];
		NSString *tmpstr;
		if ([scan scanUpToString:@"<select name=\"cat\"" intoString:NULL] &&
			[scan scanUpToString:@"</select>" intoString:&tmpstr]) {
			//		NSLog([@"Categories: " stringByAppendingString:tmpstr]);
			// Now parse the select list
			scan = [NSScanner scannerWithString:tmpstr];
			if ([scan scanUpToString:@"<option" intoString:NULL]) {
				int catid;
				NSString *catname;
				while ([scan scanString:@"<option value=\"" intoString:NULL] == YES) {
					if ([scan scanInt:&catid] &&
						[scan scanString:@"\">" intoString:NULL] &&
						[scan scanUpToString:@"</option>" intoString:&catname] &&
						[scan scanString:@"</option>" intoString:NULL]) {
						CopperAlbum *newcat = [[CopperAlbum alloc] initWithName:[catname copy] number:catid];
						//			NSLog(@"Found category: %s", [[newcat stringValue] cString]);
						[categories addObject:newcat];
						canChooseCategory = YES;
					}
					else
						NSLog(@"Error: unable to parse string: %@", tmpstr);
				}				
			}
			else
				NSLog(@"Error: unable to parse string: %@", tmpstr);
		}
		else
			NSLog(@"Error: unable to parse string: %@", resultstr);
	}
	else {
		NSLog(@"Could not find list of categories in response");
	}
	return TRUE;
}

// Return the list of albums
- (NSMutableArray *)listOfAlbums {
	return albums;
}

- (NSMutableArray *)albums {
	return albums;
}

/*
- (void) setAlbums: (NSArray *)newalbums {
	if (albums != newalbums) {
		[albums removeAllObjects];
		[albums addObjectsFromArray:newalbums];
	}
}
*/

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

/*
 - (void) setCategories: (NSArray *)newcategories {
	 if (categories != newcategories) {
		 [categories removeAllObjects];
		 [categories addObjectsFromArray:newcategories];
	 }
 }
 */

- (CopperAlbum *)selectedCategory {
	if (selectedCategory == nil) {
		if (categories && [categories count] > 0) {
			selectedCategory = [categories objectAtIndex:0];
		}
	}
	return selectedCategory;
}

- (void) setSelectedCategory:(CopperAlbum *)newcat {
	if (selectedCategory != newcat) {
		selectedCategory = newcat;
	}
}

- (CopperAlbum *)createNewAlbum: (NSString *)albumName withDescription: (NSString *)albumDesc inCategory: (int)catnumber {
	NSMutableDictionary *post_dict = [[NSMutableDictionary alloc] initWithCapacity: 2];
	NSError *error;
	[post_dict setValue:albumName		forKey:@"new_alb_name"];
	[post_dict setValue:albumDesc		forKey:@"new_alb_description"];
	[post_dict setValue:[NSString stringWithFormat:@"%d", catnumber]	forKey:@"cat"];
	
	NSString *resultstr = [self postForm:post_dict 
								   toURL:[self urlplus:@"xp_publish.php?cmd=create_album&lang=english"]
								   error:&error];
	if (!resultstr) {
		[self postError: error];
		return nil;
	}
	
	if ([resultstr rangeOfString:@"was created"].location == NSNotFound) {
		NSLog(@"Error: Could not create album '%s' - permission denied", [albumName cString]);
		return nil;
	}
	else {
		NSScanner *scan = [NSScanner scannerWithString:resultstr];
		int albnumber;
		if ([scan scanUpToString:@"name=\"album\" value =\"" intoString:NULL] &&
			[scan scanString:@"name=\"album\" value =\"" intoString:NULL] &&
			[scan scanInt:&albnumber]) {
			CopperAlbum *newalb = [[CopperAlbum alloc] initWithName:[albumName copy] number:albnumber];
			NSLog(@"Created album: %s", [[newalb stringValue] cString]);
			return newalb;			
		}
		else {
			NSLog(@"Error: unable to parse string: %@", resultstr);
			return nil;
		}
	}
}

- (BOOL) canCreateAlbums {
	return canCreateAlbums;
}

- (void) setCanCreateAlbums: (BOOL)newvalue {
	canCreateAlbums = newvalue;
}

- (BOOL) areThereAlbums {
	return areThereAlbums;
}

- (void) setAreThereAlbums: (BOOL)newvalue {
	areThereAlbums = newvalue;
}

@end

@implementation CopperUploader (PrivateAPI)
- (void)uploadNextImage {

	CpgImageRecord *image = [imageRecords objectAtIndex: cursor];
	NSLog([@"Uploading image " stringByAppendingString:[image filePath]]);
	NSString *tmpfile = [@"/tmp/" stringByAppendingPathComponent:[[image filePath] lastPathComponent]];
	
	NS_DURING
		NSFileManager *man = [NSFileManager defaultManager];
		[man copyPath: [image filePath] toPath: tmpfile handler: nil];
		
		if([image needsResize]) {
			[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderWillResizeImageAtIndex:)
														  withObject: [NSNumber numberWithInt: cursor]
													   waitUntilDone: YES];
			
			int max = [image newWidth];
			if([image newHeight] > [image newWidth])
				max = [image newHeight];
			
			[self scaleFile: tmpfile toMaxSize: max];

			[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderDidResizeImageAtIndex:)
														  withObject: [NSNumber numberWithInt: cursor]
													   waitUntilDone: YES];
		}
		
	NS_HANDLER
		NSRunAlertPanel([localException name],
						[localException reason],
						@"OK", nil, nil);
	NS_ENDHANDLER

	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	
	[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderWillUploadImageAtIndex:)
												  withObject: [NSNumber numberWithInt: cursor]
											   waitUntilDone: YES];
		
	// Phase 2 - send the file
	[post_dict setObject:[NSURL fileURLWithPath:tmpfile] forKey:@"userpicture"];
	[post_dict setValue:[image title] forKey:@"title"];
	[post_dict setValue:[image descriptionText] forKey:@"caption"];
	
	// Process tags
	NSEnumerator *tagEnum = [[image tags] objectEnumerator];
	NSMutableDictionary *tag;
	NSMutableArray *tags = [NSMutableArray array];
	while(tag = [tagEnum nextObject]) {
		id tagContent = [tag objectForKey:@"content"];
		if(tagContent) { // Don't want to add nil tag
			[tags addObject: tagContent];
		}
	}
	[post_dict setValue: [tags componentsJoinedByString: @" "] forKey:@"keywords"];

	// Now post the thing
	NSError *error;
	NSString *resultstr = [self postForm:post_dict 
								   toURL:[self urlplus:
									   [NSString stringWithFormat:@"xp_publish.php?cmd=add_picture&album=%d&lang=english",
										   [selectedAlbum number]]]
								   error:&error];
	if (!resultstr) {
		[self postError: error];
	}
	else {
		//	NSLog(@"Result from post: %s", [resultstr cString]);
		
		CopperResponse *resp = [CopperResponse responseWithString:resultstr];
		[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderReceivedResponse:)
													  withObject: resp
												   waitUntilDone: YES];		
	}
	
	[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderDidUploadImageAtIndex:)
												  withObject: [NSNumber numberWithInt: cursor]
											   waitUntilDone: YES];
	
	if ([[NSFileManager defaultManager] removeFileAtPath: tmpfile handler: nil] != YES) {
		NSLog([@"Error removing " stringByAppendingString:tmpfile]);
	}

	[post_dict release];
}

- (NSData *)generateFormData: (NSDictionary *)dict {
	NSString* boundary = formBoundary;
	NSArray* keys = [dict allKeys];
	NSMutableData* result = [[NSMutableData alloc] initWithCapacity:100];
	
	int i;
	for (i = 0; i < [keys count]; i++) 
	{
		id value = [dict valueForKey: [keys objectAtIndex: i]];
		
		[result appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

		if ([value class] != [NSURL class]) {
			[result appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"\n\n", [keys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSISOLatin1StringEncoding]];
		}
		else if ([value class] == [NSURL class] && [value isFileURL]) {
			NSString *disposition = [NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", [keys objectAtIndex:i], [[value path] lastPathComponent]];
			[result appendData: [disposition dataUsingEncoding:NSUTF8StringEncoding]];
			
			[result appendData:[[NSString stringWithString: @"Content-Type: application/octet-stream\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
		}
		[result appendData:[[NSString stringWithString:@"\n"]
       dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [result autorelease];
}

- (void)scaleFile: (NSString *)file toMaxSize: (int)maxLength {
	NSTask *sips = [[NSTask alloc] init];
	[sips setLaunchPath: @"/usr/bin/sips"];
	
	NSArray *args = [NSArray arrayWithObjects: file, @"-Z", [NSString stringWithFormat: @"%d", maxLength], nil];
	[sips setArguments: args];
	[sips launch];
	[sips waitUntilExit];
	[sips release];
}

- (NSString *)postForm: (NSMutableDictionary *)post_dict toURL: (NSString *)urlstr error: (NSError **)err {
	NSData *regData = [self generateFormData:post_dict];
	NSURL* url = [NSURL URLWithString:urlstr];
	
	NSLog(@"Posting to URL: %s", [urlstr cString]);
	
	NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:url];
	
	NSString *boundaryString = [NSString stringWithFormat: @"multipart/form-data; boundary=%@", formBoundary];
	[post addValue: boundaryString forHTTPHeaderField: @"Content-Type"];
	[post setHTTPMethod:@"POST"];
	[post setHTTPBody:regData];
	
	NSHTTPURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest: post
										   returningResponse: &response
													   error: err];
	
	if (*err) {
		NSLog(@"###### Error: code=%d, domain=%s, localizedDesc=%s", [*err code], [[*err domain] cString], [[*err localizedDescription] cString]);
		return nil;
	}
	if ([response statusCode] < 200 || [response statusCode] >= 300) {
		NSDictionary *errdict;
		
		NSLog(@"HTTP status code: %d, response string: %s", [response statusCode], [[NSHTTPURLResponse localizedStringForStatusCode: [response statusCode]] cString]);

		if ([response statusCode] == 404) {
			errdict = [NSDictionary dictionaryWithObject:
				@"I cannot find the file /xp_publish.php under the URL you specified. "
				"Please make sure you entered the base URL for your gallery "
				"(where the album list appears), and that it ends with a slash (/) or "
				"with /index.php."
												  forKey: NSLocalizedDescriptionKey];
		}
		else {
			errdict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"HTTP Error %d: %s",
																[response statusCode],
																[[NSHTTPURLResponse localizedStringForStatusCode: [response statusCode]] cString]]
												  forKey:NSLocalizedDescriptionKey];
		}
		*err = [NSError errorWithDomain:NSURLErrorDomain code:[response statusCode] userInfo:errdict];
		return nil;
	}
		
	return [[[NSString alloc] initWithData:result encoding:NSISOLatin1StringEncoding] autorelease];
}

- (NSString *)urlplus: (NSString *)suffix {
	NSMutableString *urlString = [NSMutableString stringWithCapacity: 100];
	[urlString appendString: [self cpgurl]];
	[urlString appendString: suffix];
	return urlString;
}

- (void)postError: (NSError *)error {
	CopperResponse *resp;
	if ([error code] == -1003)
		resp = [CopperResponse responseWithString:NSLocalizedString(@"Error: Host not found. Please make sure the hostname you entered is correct.",
																	@"Host not found error. Start this string with 'Error: '")];
	else
		resp = [CopperResponse responseWithString:[NSString stringWithFormat:@"Error: %s (code %d)", [[error localizedDescription] cString], [error code]]];
	[self postResponse: resp];
	[self cancelUpload];
}

- (void)postResponse: (CopperResponse *)resp {
	[(NSObject *)[self delegate] performSelectorOnMainThread: @selector(uploaderReceivedResponse:)
												  withObject: resp
											   waitUntilDone: YES];
}

@end
