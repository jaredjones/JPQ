/*
 *  JPQLib.h
 *  JPQLib
 *
 *  Created by Jared Jones on 11/2/14.
 *  Copyright (c) 2014 Uvora. All rights reserved.
 *
 */

#ifndef JPQLib_
#define JPQLib_

/* The classes below are exported */
#pragma GCC visibility push(default)

#include <string>

#include "Common.h"
#include "SpookyV2.h"

class JPQLib
{
private:
    std::string _filePath;
    uint16 _fileVersion;
    uint32 _maxNumberOfFiles;
    uint8 _filePositionSizeInBytes;
    uint64 _indexSeed;
    uint32 _collisionSeed;
    uint64 _hTBeginIndex;
    uint64 _dataBlockIndex;
    uint64 _dataBlockEnd;
public:
    JPQLib();
    void CreateJPQPackage(std::string path, uint32 maxNumberOfFiles = 1024, uint16 version = JPQ_DEFAULT_VERSION,
                          uint8 filePositionSizeInBytes = 8);
    void LoadJPQPackage(std::string path);
    void AddFile(std::string localPath, std::string jpqIndexPath);
    void PrintLocalVariables();
};

#pragma GCC visibility pop
#endif
