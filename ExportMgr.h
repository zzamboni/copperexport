/*
 *  ExportMgr.h
 *  FlickrExport
 *
 *  Created by Fraser Speirs on 14/08/2004.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#include <Cocoa/Cocoa.h>
#include "ExportImageProtocol.h"

@interface ExportMgr : NSObject <ExportImageProtocol> {}
+ (id)exportMgr;
+ (id)exportMgrNoAlloc;
- (id)init;
- (void)dealloc;
- (void)releasePlugins;
- (void)setExportController:(id)fp12;
- (id)exportController;
- (void)setDocument:(id)fp12;
- (id)document;
- (void)updateDocumentSelection;
- (unsigned int)count;
- (id)recAtIndex:(unsigned int)fp12;
- (void)scanForExporters;
- (unsigned int)imageCount;
- (BOOL)imageIsPortraitAtIndex:(unsigned int)fp12;
- (id)imagePathAtIndex:(unsigned int)fp12;
- (struct _NSSize)imageSizeAtIndex:(unsigned int)fp16;
- (unsigned int)imageFormatAtIndex:(unsigned int)fp12;
- (id)imageCaptionAtIndex:(unsigned int)fp12;
- (id)thumbnailPathAtIndex:(unsigned int)fp12;
- (id)imageDictionaryAtIndex:(unsigned int)fp12;
- (float)imageAspectRatioAtIndex:(unsigned int)fp12;
- (void)commitImageRotation;
- (id)selectedAlbums;
- (id)albumName;
- (id)albumMusicPath;
- (unsigned int)albumCount;
- (unsigned int)albumPositionOfImageAtIndex:(unsigned int)fp12;
- (id)imageRecAtIndex:(unsigned int)fp12;
- (id)currentAlbum;
- (void)enableControls;
- (void)disableControls;
- (id)window;
- (void)clickExport;
- (void)startExport;
- (void)cancelExport;
- (void)cancelExportBeforeBeginning;
- (id)directoryPath;
- (id)temporaryDirectory;
- (BOOL)doesFileExist:(id)fp12;
- (BOOL)doesDirectoryExist:(id)fp12;
- (BOOL)createDir:(id)fp12;
- (id)uniqueSubPath:(id)fp12 child:(id)fp16;
- (id)makeUniquePath:(id)fp12;
- (id)makeUniqueFilePath:(id)fp12 extension:(id)fp16;
- (id)makeUniqueFileNameWithTime:(id)fp12;
- (BOOL)makeFSSpec:(id)fp12 spec:(struct FSSpec *)fp16;
- (id)pathForFSSpec:(id)fp12;
- (BOOL)getFSRef:(struct FSRef *)fp12 forPath:(id)fp16 isDirectory:(BOOL)fp20;
- (id)pathForFSRef:(struct FSRef *)fp12;
- (unsigned long)countFiles:(id)fp12 descend:(BOOL)fp16;
- (unsigned long)countFilesFromArray:(id)fp12 descend:(BOOL)fp16;
- (unsigned long long)sizeAtPath:(id)fp12 count:(unsigned long *)fp16 physical:(BOOL)fp20;
- (BOOL)isAliasFileAtPath:(id)fp12;
- (id)pathContentOfAliasAtPath:(id)fp12;
- (id)stringByResolvingAliasesInPath:(id)fp12;
- (BOOL)ensurePermissions:(unsigned long)fp12 forPath:(id)fp16;
- (id)validFilename:(id)fp12;
- (id)getExtensionForImageFormat:(unsigned int)fp12;
- (unsigned int)getImageFormatForExtension:(id)fp12;
- (struct OpaqueGrafPtr *)uncompressImage:(id)fp12 size:(struct _NSSize)fp16 pixelFormat:(unsigned int)fp24 rotation:(float)fp40 colorProfile:(char ***)fp32;
- (void *)createThumbnailer;
- (void *)retainThumbnailer:(void *)fp12;
- (void *)autoreleaseThumbnailer:(void *)fp12;
- (void)releaseThumbnailer:(void *)fp12;
- (void)setThumbnailer:(void *)fp12 maxBytes:(unsigned int)fp16 maxWidth:(unsigned int)fp20 maxHeight:(unsigned int)fp24;
- (struct _NSSize)thumbnailerMaxBounds:(void *)fp16;
- (void)setThumbnailer:(void *)fp12 quality:(int)fp16;
- (int)thumbnailerQuality:(void *)fp12;
- (void)setThumbnailer:(void *)fp12 rotation:(float)fp40;
- (float)thumbnailerRotation:(void *)fp12;
- (void)setThumbnailer:(void *)fp12 outputFormat:(unsigned int)fp16;
- (unsigned int)thumbnailerOutputFormat:(void *)fp12;
- (void)setThumbnailer:(void *)fp12 outputExtension:(id)fp16;
- (id)thumbnailerOutputExtension:(void *)fp12;
- (BOOL)thumbnailer:(void *)fp12 createThumbnail:(id)fp16 dest:(id)fp20;
- (struct _NSSize)lastImageSize:(void *)fp16;
- (struct _NSSize)lastThumbnailSize:(void *)fp16;

@end

@interface ExportMgr (iPhoto5Additions)
- (id)imageKeywordsAtIndex:(unsigned int)fp8;
- (id)imageCommentsAtIndex:(unsigned int)fp8;
@end