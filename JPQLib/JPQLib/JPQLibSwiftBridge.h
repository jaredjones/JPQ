//
//  JPQLibCPlusPlusBridge.h
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#import <Foundation/Foundation.h>

//NOTE: DUE TO SWIFT INTEGRATION THIS FILE CANNOT CONTAIN ANY C++ CODE OR ANY INCLUDES WHICH MIGHT
//      CONTAIN C++ CODE; ONLY C++ CODE THAT HIDES BEHIND A HEADER FILE WRITTEN IN ANSI-C (C99) IS VALID!



@interface JPQFileSwiftBridge : NSObject
@property void* file;
@property uint32 errorCode;
- (instancetype)init;
- (void)Reopen;
- (void)Close;
- (void)Clear;
//- (void)EmptyFolderList: (FolderListSwiftBridge *) list;
- (void)AddFile: (NSString *)localFilePath withJPQFilePath:(NSString *)jpqFilePath replaceIfExists:(BOOL)replaceIfExists addToDir:(BOOL)addToDir overrideFileFormatCheck:(BOOL)overrideFileFormatCheck;
- (NSData *)LoadFile: (NSString *)jpqFilePath withFileSize: (UInt64 *)fileSize;
- (NSNumber *)GetNumberOfFiles;
- (void)DisplayFileVariables;
- (void)dealloc;
@end


@interface JPQLibSwiftBridge : NSObject
- (instancetype)init;
+ (UInt8)getJPQHeaderSize;
+ (JPQFileSwiftBridge *)CreateJPQPackage:(NSString *)localFilePath withOverwriteFile:(BOOL)overwriteFile withMaxNumberOfFiles:(NSNumber *)maxNumberOfFiles withVersion:(NSNumber *)version withFilePositionSizeInBytes:(NSNumber *)filePositionSizeInBytes;
+ (JPQFileSwiftBridge *)LoadJPQPackage:(NSString *)localFilePath;
@end
