//
//  JPQLibCPlusPlusBridge.m
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#import "JPQLibSwiftBridge.h"
#import "JPQLib.h"
#import "JPQHardware.h"

@implementation JPQLibSwiftBridge
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        UpdateCPUFlags();
        if (!HW_SSE2)
        {
            printf("Your hardware does not support SSE2!\n");
            self = nil;
            return nil;
        }
        /*
        //TESTING
        JPQFile *file;
        file = JPQLib::CreateJPQPackage(std::string("/Users/jared/Desktop/Test.JPQ"),true,10,1,4);
        
        //file = JPQLib::LoadJPQPackage(std::string("/Users/jared/Desktop/Test.JPQ"));
        file->DisplayFileVariables();
        NSLog(@"Num Files:%llu\n", file->GetNumberOfFiles());
        
        file->AddFile(std::string("/Users/jared/Desktop/a.txt"), std::string("dufus/marcus/a.txt"), false, true);
        file->AddFile(std::string("/Users/jared/Desktop/b.txt"), std::string("dufus/marcus/b.txt"), false, true);
        file->AddFile(std::string("/Users/jared/Desktop/c.txt"), std::string("dufus/marcus/c.txt"), false, true);

        //file->AddFile(std::string("/Users/jared/Desktop/a.txt"), std::string("dufus/marcus/a.txt"), false, true);
        
        uint64 fileSize;
        void* loadedFile = file->LoadFile(std::string("dufus/marcus/a.txt"), &fileSize);
        
        
        
        
        free(loadedFile);
        loadedFile = nullptr;
        */
        // JPQLib consists only of static classes at the moment;
        // therefore there is nothing to instantiate.
    }
    return self;
}

+ (JPQFileSwiftBridge *)CreateJPQPackage:(NSString *)localFilePath withOverwriteFile:(BOOL)overwriteFile withMaxNumberOfFiles:(NSNumber *)maxNumberOfFiles withVersion:(NSNumber *)version withFilePositionSizeInBytes:(NSNumber *)filePositionSizeInBytes
{
    BOOL defaultOverwriteFile = JPQ_DEFAULT_OVERWRITEFILE;
    UInt32 defaultMaxNumberOfFiles = JPQ_DEFAULT_MAXFILES;
    UInt16 defaultJPQVersion = JPQ_DEFAULT_VERSION;
    UInt8 defaultFilePositionSizeInBytes = JPQ_DEFAULT_FILE_POSITION_SIZE_IN_BYTES;
    
    if (overwriteFile)
        defaultOverwriteFile = !(defaultOverwriteFile);
    if (maxNumberOfFiles != nil)
        defaultMaxNumberOfFiles = [maxNumberOfFiles unsignedIntValue];
    if (version != nil)
        defaultJPQVersion = [version unsignedShortValue];
    if (filePositionSizeInBytes != nil)
        defaultFilePositionSizeInBytes = [filePositionSizeInBytes unsignedCharValue];
    
    JPQFile *file = JPQLib::CreateJPQPackage(std::string([localFilePath UTF8String]),
                                             defaultOverwriteFile,
                                             defaultMaxNumberOfFiles,
                                             defaultJPQVersion,
                                             defaultFilePositionSizeInBytes);
    JPQFileSwiftBridge *tmpFileBridge = [[JPQFileSwiftBridge alloc]init];
    [tmpFileBridge setFile:file];
    [tmpFileBridge setErrorCode:file->GetErrorCode()];
    return tmpFileBridge;
}

+ (JPQFileSwiftBridge *)LoadJPQPackage:(NSString *)localFilePath
{
    JPQFile *file = JPQLib::LoadJPQPackage(std::string([localFilePath UTF8String]));
    JPQFileSwiftBridge *tmpFileBridge = [[JPQFileSwiftBridge alloc]init];
    [tmpFileBridge setFile:file];
    [tmpFileBridge setErrorCode:file->GetErrorCode()];
    return tmpFileBridge;
}

+ (UInt8)getJPQHeaderSize
{
    return JPQ_HEADER_SIZE;
}

@end


@implementation JPQFileSwiftBridge

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Don't need to instantiate the JPQFile since this is ONLY done by the JPQLib!
        // Not to mention you can't anyway since the instatiator is private.
    }
    return self;
}

- (void)Reopen
{
    JPQFile *file = (JPQFile *)_file;
    file->Reopen();
}

- (void)Close
{
    JPQFile *file = (JPQFile *)_file;
    file->Close();
}

- (void)Clear
{
    JPQFile *file = (JPQFile *)_file;
    file->Clear();
}

- (void)EmptyFolderList: (FolderList *) list
{
    JPQFile *file = (JPQFile *)_file;
    file->EmptyFolderList(list);
}

- (void)AddFile: (NSString *)localFilePath withJPQFilePath:(NSString *)jpqFilePath replaceIfExists:(BOOL)replaceIfExists addToDir:(BOOL)addToDir overrideFileFormatCheck:(BOOL)overrideFileFormatCheck
{
    JPQFile *file = (JPQFile *)_file;
    file->AddFile(std::string([localFilePath UTF8String]), std::string([localFilePath UTF8String]), replaceIfExists, addToDir, overrideFileFormatCheck);
}

- (NSData *)LoadFile: (NSString *)jpqFilePath withFileSize: (UInt64 *)fileSize
{
    JPQFile *file = (JPQFile *)_file;
    void* data = file->LoadFile([jpqFilePath UTF8String], fileSize);
    return [NSData dataWithBytes:data length:*fileSize];
}

- (NSNumber *)GetNumberOfFiles
{
    JPQFile *file = (JPQFile *)_file;
    UInt64 fileCount = file->GetNumberOfFiles();
    return [NSNumber numberWithUnsignedLongLong:fileCount];
}

- (void)DisplayFileVariables
{
    JPQFile *file = (JPQFile *)_file;
    file->DisplayFileVariables();
}

- (void)dealloc
{
    if (self.file != nil)
    {
        JPQFile *file = (JPQFile *)_file;
        delete file;
        _file = nil;
    }
}

@end