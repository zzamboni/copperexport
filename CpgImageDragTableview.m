// Originally called ImageDragTableview.m
//
//  CpgImageDragTableview.m
//  CopperExport
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


#import "CpgImageDragTableview.h"
#import "CpgDNDArrayController.h"
#import "CpgImageRecord.h"

@implementation CpgImageDragTableview
- (NSImage *)dragImageForRows:(NSArray *)dragRows 
						event:(NSEvent *)dragEvent
			  dragImageOffset:(NSPointPointer)dragImageOffset 
{
	/* This is eye candy for when we're dragging rows in the table. */
	int rowNumber = [[dragRows objectAtIndex: 0] intValue];
	
	CpgImageRecord *rec = [[(CpgDNDArrayController *)[self delegate] arrangedObjects] objectAtIndex: rowNumber];
	
	NSImage *thumb = [[[NSImage alloc] initWithData: [rec thumbnailData]] autorelease];
	[thumb setScalesWhenResized: YES];
	
	NSSize thumbnailSize;
	int kThumbLongestSide = 50;
	// Check if it's landscape
	if([thumb size].width > [thumb size].height) {
		float factor = [thumb size].width/kThumbLongestSide;
		thumbnailSize = NSMakeSize(kThumbLongestSide, [thumb size].height/factor);
	} else {
		float factor = [thumb size].height/kThumbLongestSide;
		thumbnailSize = NSMakeSize([thumb size].width/factor, kThumbLongestSide);
	}

	[thumb setSize: thumbnailSize];
	return thumb;
}
@end
