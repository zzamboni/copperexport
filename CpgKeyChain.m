// Originally called FUKeyChain.m
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

#import "CpgKeyChain.h"

static CpgKeyChain* defaultKeyChain;

@interface CpgKeyChain (PrivateAPI)

- (KCItemRef)refForService:(NSString *)service account:(NSString*)account;

@end

@implementation CpgKeyChain

+ (CpgKeyChain*) defaultKeyChain {
	if(!defaultKeyChain)
		defaultKeyChain = [[CpgKeyChain alloc] init];
		
	return defaultKeyChain;
}

- (id)init
{
    self = [super init];
    maxLen = 127;
    return self;
}

- (void)setPassword:(NSString*)password forService:(NSString *)service account:(NSString*)account
{
    OSStatus ret;
    KCItemRef itemref = NULL;
    void *p = (void *)malloc(128 * sizeof(char));
    
    if ([service length] == 0 || [account length] == 0) {
        return ;
    }
    
    if (!password || [password length] == 0) {
        [self removePasswordForService:service account:account];
    } else {
        strcpy(p,[password cString]);
    
        if (itemref = [self refForService:service account:account])
			KCDeleteItem(itemref);
        ret = kcaddgenericpassword([service cString], [account cString], [password cStringLength], p, NULL);
        free(p); 
    }
}

- (NSString*)passwordForService:(NSString *)service account:(NSString*)account
{
    OSStatus ret;
    UInt32 length;
    void *p = (void *)malloc(maxLen * sizeof(char));
    NSString *string = @"";
    
    if ([service length] == 0 || [account length] == 0) {
        free(p);
		// Should probably raise an exception here.
    }
    
    ret = kcfindgenericpassword([service cString], [account cString], maxLen-1, p, &length, nil);

    if (!ret)
        string = [NSString stringWithCString:(const char*)p length:length];
    free(p); 
	
	if([string length] == 0)
		return nil;
    return string;
}

- (void)removePasswordForService:(NSString *)service account:(NSString*)account
{
    KCItemRef itemref = nil ;
    if (itemref = [self refForService:service account:account])
        KCDeleteItem(itemref);
}
@end

@implementation CpgKeyChain (PrivateAPI)

- (KCItemRef)refForService:(NSString *)service account:(NSString*)account
{
    KCItemRef itemref = nil;
    kcfindgenericpassword([service cString],[account cString],nil,nil,nil,&itemref);
    return itemref;
}

@end
