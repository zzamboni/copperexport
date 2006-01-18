// Originally called DNDArrayController.h
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

/*
 * NOTICE: This class is based on Apple Sample Code from:
 *
 * http://homepage.mac.com/mmalc/CocoaExamples/controllers.html
 *
 * IANAL, but it appears that I am allowed to relicense derivative works
 * as I see fit.  If this is wrong, and anyone cares, please email
 * me and we'll work it out.
 */
#import <Cocoa/Cocoa.h>


@interface CpgDNDArrayController : NSArrayController
{
    IBOutlet NSTableView *tableView;
	
	NSString *searchTerm;
}

- (IBAction)search: (id)sender;
- (NSString *)searchTerm;
- (void)setSearchTerm:(NSString *)aSearchTerm;

// table view drag and drop support

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard;
    
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
    
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;

- (NSTableView *)tableView;


// utility methods

-(void)moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet *)indexSet 
				    toIndex:(unsigned)index;

- (NSIndexSet *)indexSetFromRows:(NSArray *)rows;
- (int)rowsAboveRow:(int)row inIndexSet:(NSIndexSet *)indexSet;

@end
