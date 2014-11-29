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
#include "JPQFile.h"

class JPQLib
{
public:
    static JPQFile* CreateJPQPackage(std::string localFilePath, uint32 maxNumberOfFiles = JPQ_DEFAULT_MAXFILES, uint16 version = JPQ_DEFAULT_VERSION,
                          uint8 filePositionSizeInBytes = JPQ_DEFAULT_FILEPOSITIONSIZEINBYTES);
    static JPQFile* LoadJPQPackage(std::string localFilePath);
   
};

#pragma GCC visibility pop
#endif
