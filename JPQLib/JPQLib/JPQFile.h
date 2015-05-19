//
//  JPQFile.h
//  JPQLib
//
//  Created by Jared Jones on 11/28/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#ifndef __JPQLib__JPQFile__
#define __JPQLib__JPQFile__

#include <stdlib.h>
#include <string>
#include "Common.h"
#include "SpookyV2.h"

enum class JPQFileError : uint32
{
    NO_ERROR            = 0x0,
    UNKOWN_ERROR        = 0x1,
    ALREADY_EXISTS      = 0x2,
    WRITE_ACCESS_DENIED = 0x4,
    READ_ACCESS_DENIED  = 0x8,
    MALLOC_ERROR        = 0x10,
    JPQ_FILE_NULL       = 0x20,
    JPQ_FILE_NOT_FOUND  = 0x40
};

struct FolderList
{
    char* s = nullptr;
    FolderList *next = nullptr;
    ~FolderList()
    {
        // Perhaps smart pointers with reference counting should be used instead?
        // meh, speed is better in my opinion than reference counts.
        printf("MEMORY LEAK: The data inside of this list is now dormant.\
               please delete this object with: EmptyFolderList(FolderList *list\n");
    }
};

class JPQFile
{
    friend class JPQLib;
public:
    uint32 GetErrorCode();
private:
    JPQFile()
    {
        Clear();
    }
    bool _fileExists(std::string jpqFilePath);
    void _addFile(void *data, uint64 fileSize, std::string jpqFilePath, bool replaceIfExists, bool addToDir);
    void _replaceFile(void *data, uint64 fileSize, std::string jpqFilePath);
    FolderList* _createListOfFoldersFromPath(char* jpqFilePath);
    FILE *_jpqFile;
    std::string _filePath;
    uint16 _fileVersion;
    uint32 _maxNumberOfFiles;
    uint8 _filePositionSizeInBytes;
    uint64 _indexSeed;
    uint32 _collisionSeed;
    uint64 _hTBeginIndex;
    uint64 _dataBlockIndex;
    uint64 _dataBlockEnd;
    
    uint32 _errorCode = 0;
public:
    ~JPQFile()
    {
        fclose(_jpqFile);
        _jpqFile = nullptr;
    }
    void Reopen();
    void Close();
    void Clear();
    void AddFile(std::string localFilePath, std::string jpqFilePath, bool replaceIfExists = false, bool addToDir = true, bool overrideFileFormatCheck = false);
    void* LoadFile(std::string path, uint64 *fileSize);
    void DeleteFile(std::string path);
    uint64 GetNumberOfFiles();
    void DisplayFileVariables();
    void EmptyFolderList(FolderList *list);
};

#endif /* defined(__JPQLib__JPQFile__) */
