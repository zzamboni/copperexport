//
//  CopperAlbum.m
//  CopperExport
//
//  Created by Diego Zamboni on 1/16/05.
// Copyright (c) 2005, Diego Zamboni
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
//     * Neither the name of Diego Zamboni nor the names of its contributors may be
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
//

#import "CopperAlbum.h"

@implementation CopperAlbum

-(id)initWithName: (NSString *)newname number: (int) newnumber {
	self = [super init];
	if (self) {
		[self setName: newname];
		[self setNumber: newnumber];
	}
	return self;
}

-(void)setName: (NSString *)newname {
	if (name != newname) {
		[newname retain];
		[name release];
		name = newname;
	}
}

-(NSString*) name {
	return name;
}

-(void)setNumber: (int)newnumber {
	number = newnumber;
}

-(int)number {
	return number;
}

-(NSString *)stringValue {
	return [NSString stringWithFormat:@"%s (%d)", [[self name] cString], [self number]];
}

@end
