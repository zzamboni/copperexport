// Originally called DNDArrayController.m
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

#import "CpgDNDArrayController.h"
#import "CpgImageRecord.h"

NSString *MovedRowsType = @"CopperCpgImageRecordType";

@implementation CpgDNDArrayController

- (void)awakeFromNib
{
    // register for drag and drop
    [tableView registerForDraggedTypes: [NSArray arrayWithObject: MovedRowsType]];
	[tableView setVerticalMotionCanBeginDrag: YES];
}

- (IBAction)search: (id)sender {
	[self setSearchTerm: [sender stringValue]];
}

//=========================================================== 
// - searchTerm:
//=========================================================== 
- (NSString *)searchTerm {
    return searchTerm; 
}

//=========================================================== 
// - setSearchTerm:
//=========================================================== 
- (void)setSearchTerm:(NSString *)aSearchTerm {
    [searchTerm release];
    searchTerm = [aSearchTerm copy];
	[self rearrangeObjects];
}

- (NSArray *)arrangeObjects:(NSArray *)objects
{
	if ((searchTerm == nil) ||
		([searchTerm isEqualToString:@""]))
	{
		return [super arrangeObjects:objects];   
	}

	/*
	 Create array of objects that match search string.
	 Also add any newly-created object unconditionally:
	 (a) You'll get an error if a newly-added object isn't added to
	 arrangedObjects.
	 (b) The user will see newly-added objects even if they don't
	 match the search term.
	 */

	NSMutableArray *matchedObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    // case-insensitive search
	NSString *lowerSearch = [searchTerm lowercaseString];

	NSEnumerator *oEnum = [objects objectEnumerator];
	CpgImageRecord *item;	
	while (item = [oEnum nextObject])
	{
			// Use of local autorelease pool here is probably overkill,
			// but may be useful in a larger-scale application.
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if([item metadataContainsString: searchTerm])
			[matchedObjects addObject: item];
		
		[pool release];
	}

	return [super arrangeObjects:matchedObjects];
}

// End seraching support

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	// declare our own pasteboard types
    NSArray *typesArray = [NSArray arrayWithObject: MovedRowsType];
	[pboard declareTypes:typesArray owner:self];
		
    // add rows array for local move
    [pboard setPropertyList:rows forType:MovedRowsType];
	
    return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op 
{
    NSDragOperation dragOp = NSDragOperationNone;
    
    // if drag source is self, it's a move
    if ([info draggingSource] == tableView)
	{
		dragOp =  NSDragOperationMove;
    }
    // we want to put the object at, not over,
    // the current row (contrast NSTableViewDropOn) 
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return dragOp;
}



- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
    if (row < 0)
	{
		row = 0;
	}
    
    // if drag source is self, it's a move
    if ([info draggingSource] == tableView)
    {
		NSArray *rows = [[info draggingPasteboard] propertyListForType:MovedRowsType];

		NSIndexSet  *indexSet = [self indexSetFromRows:rows];
		
		[self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
		
		// set selected rows to those that were just moved
		// Need to work out what moved where to determine proper selection...
		int rowsAbove = [self rowsAboveRow:row inIndexSet:indexSet];
		
		NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
		indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
		[self setSelectionIndexes:indexSet];
		
		return YES;
    }
	
	
    return NO;
}



-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet
										toIndex:(unsigned int)insertIndex
{
	
    NSArray		*objects = [self arrangedObjects];
	int			index = [indexSet lastIndex];
	
    int			aboveInsertIndexCount = 0;
    id			object;
    int			removeIndex;
	
    while (NSNotFound != index)
	{
		if (index >= insertIndex) {
			removeIndex = index + aboveInsertIndexCount;
			aboveInsertIndexCount += 1;
		}
		else
		{
			removeIndex = index;
			insertIndex -= 1;
		}
		object = [objects objectAtIndex:removeIndex];
		[self removeObjectAtArrangedObjectIndex:removeIndex];
		[self insertObject:object atArrangedObjectIndex:insertIndex];
		
		index = [indexSet indexLessThanIndex:index];
    }
}


- (NSIndexSet *)indexSetFromRows:(NSArray *)rows
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSEnumerator *rowEnumerator = [rows objectEnumerator];
    NSNumber *idx;
    while (idx = [rowEnumerator nextObject])
    {
		[indexSet addIndex:[idx intValue]];
    }
    return indexSet;
}


- (int)rowsAboveRow:(int)row inIndexSet:(NSIndexSet *)indexSet
{
    unsigned currentIndex = [indexSet firstIndex];
    int i = 0;
    while (currentIndex != NSNotFound)
    {
		if (currentIndex < row) { i++; }
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}

@end