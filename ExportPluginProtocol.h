/*
 *  ExportPluginProtocol.h
 *  CopperExport
 *
 *  Created by Fraser Speirs on 14/08/2004.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#include <Cocoa/Cocoa.h>

@protocol ExportPluginProtocol
- (id)description;
- (id)name;
- (void)cancelExport;
- (void)unlockProgress;
- (void)lockProgress;
- (void *)progress;
- (void)performExport:(id)fp8;
- (void)startExport:(id)fp8;
- (void)clickExport;
- (BOOL)validateUserCreatedPath:(id)fp8;
- (BOOL)treatSingleSelectionDifferently;
- (id)defaultDirectory;
- (id)defaultFileName;
- (id)getDestinationPath;
- (BOOL)wantsDestinationPrompt;
- (id)requiredFileType;
- (void)viewWillBeDeactivated;
- (void)viewWillBeActivated;
- (id)lastView;
- (id)firstView;
- (id)settingsView;
- (id)initWithExportImageObj:(id)fp8;
@end