//
//  CopperResponse.m
//
// Copyright (c) 2005, Diego Zamboni
// Based on code by Fraser Speirs, original license shown below.
// Originally called FlickrResponse.m
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

#import "CopperResponse.h"


@implementation CopperResponse
+ (id)responseWithString: (NSString *)responseString {
	return [[[CopperResponse alloc] initWithString: responseString] autorelease];
}

- (id)initWithString: (NSString *)responseString {
	self = [super init];
	if(self) {
		[self setStr: responseString];
		
		// Scan string
		if ([str rangeOfString:@"SUCCESS"].location != NSNotFound) {
			[self setStatus: CpgStatusOK];
		}
		else if ([str rangeOfString:@"Critical error"].location != NSNotFound) {
			[self setStatus: CpgStatusCritError];
		}
		else if ([str rangeOfString:@"Error"].location != NSNotFound) {
			[self setStatus: CpgStatusError];
		}
		else {
			[self setStatus: CpgStatusUnknown];
		}
	}
	return self;
}

// ===========================================================
// - str:
// ===========================================================
- (NSString *)str {
    return str;
}

// ===========================================================
// - setStr:
// ===========================================================
- (void)setStr:(NSString *)aStr {
    if (str != aStr) {
        [aStr retain];
        [str release];
        str = aStr;
    }
}

// ===========================================================
// - status:
// ===========================================================
- (int)status {
	
    return status;
}

// ===========================================================
// - setStatus:
// ===========================================================
- (void)setStatus:(int)aStatus {
	status = aStatus;
}

/*
// ===========================================================
// - photoid:
// ===========================================================
- (int)photoid {
	
    return photoid;
}

// ===========================================================
// - setPhotoid:
// ===========================================================
- (void)setPhotoid:(int)aPhotoid {
	photoid = aPhotoid;
}

// ===========================================================
// - uploadIndex:
// ===========================================================
- (int)uploadIndex {
	
    return uploadIndex;
}

// ===========================================================
// - setUploadIndex:
// ===========================================================
- (void)setUploadIndex:(int)anUploadIndex {
	uploadIndex = anUploadIndex;
}

// ===========================================================
// - error:
// ===========================================================
- (int)error {
	
    return error;
}

// ===========================================================
// - setError:
// ===========================================================
- (void)setError:(int)anError {
	error = anError;
}
*/

@end
