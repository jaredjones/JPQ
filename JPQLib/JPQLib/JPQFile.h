//
//  JPQFile.h
//  JPQLib
//
//  Created by Jared Jones on 11/28/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#ifndef __JPQLib__JPQFile__
#define __JPQLib__JPQFile__

#include <string>

#include "Common.h"

class JPQFile
{
    friend class JPQLib;
private:
    JPQFile();
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
    void AddFile(std::string localFilePath, std::string jpqFilePath);
    void DisplayFileVariables();
};

#endif /* defined(__JPQLib__JPQFile__) */
