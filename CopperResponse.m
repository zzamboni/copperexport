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
+ (id)responseWithXML: (NSString *)xmlString imageIndex: (int)idx {
	return [[[CopperResponse alloc] initWithXML: xmlString imageIndex: idx] autorelease];
}

- (id)initWithXML: (NSString *)xmlString imageIndex: (int)idx {
	self = [super init];
	if(self) {
		[self setXml: xmlString];
		[self setUploadIndex: idx];
		
		// Scan XML
		NSString *temp;
		NSScanner *scan = [NSScanner scannerWithString: [self xml]];
		[scan scanUpToString: @"<status>" intoString: NULL];
		[scan scanString: @"<status>" intoString: NULL];
		[scan scanUpToString: @"</status>" intoString: &temp];
		[self setStatus: [temp isEqualToString:@"ok"] ? FRStatusOK : FRStatusFail];
		
		
		if([self status] == FRStatusFail) {
			// Parse the errno
			[scan scanUpToString: @"<error>" intoString: NULL];
			[scan scanString: @"<error>" intoString: NULL];
			int err;
			[scan scanInt: &err];
			[self setError: err];
		}
		else {
			[self setError: 0];
			[scan scanUpToString:@"<photoid>" intoString: NULL];
			[scan scanString:@"<photoid>" intoString: NULL];
			int picid;
			[scan scanInt: &picid];
			[self setPhotoid: picid];
		}
	}
	return self;
}
// ===========================================================
// - xml:
// ===========================================================
- (NSString *)xml {
    return xml; 
}

// ===========================================================
// - setXml:
// ===========================================================
- (void)setXml:(NSString *)aXml {
    if (xml != aXml) {
        [aXml retain];
        [xml release];
        xml = aXml;
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
@end
