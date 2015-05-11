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
        
        //TESTING
        JPQFile *file;
        //file = JPQLib::CreateJPQPackage(std::string("/Users/jared/Desktop/Test.JPQ"),true,10,1,4);
        
        file = JPQLib::LoadJPQPackage(std::string("/Users/jared/Desktop/Test.JPQ"));
        file->DisplayFileVariables();
        NSLog(@"Num Files:%llu\n", file->GetNumberOfFiles());
        
        file->AddFile(std::string("/Users/jared/Desktop/a.txt"), std::string("dufus/marcus/a.txt"));
        
        uint64 fileSize;
        void* loadedFile = file->LoadFile(std::string("/a.txt"), &fileSize);
        
        
        
        
        free(loadedFile);
        loadedFile = nullptr;
        
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

- (void)dealloc
{
    if (self.file != nil)
    {
        JPQFile *file = (JPQFile*)_file;
        delete file;
        _file = nil;
    }
}

@end