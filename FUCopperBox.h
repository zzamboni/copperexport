// Originally called FUFlickrBox.h
//
//  CopperBox.h
//  CopperExport
//
//  Created by Fraser Speirs on 14/08/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ExportPluginBoxProtocol
- (char)performKeyEquivalent:fp16;
@end

@interface FUCopperBox:NSBox <ExportPluginBoxProtocol>
{
	id mPlugin;
}
@end