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
    static JPQFile* CreateJPQPackage(std::string path, uint32 maxNumberOfFiles = 1024, uint16 version = JPQ_DEFAULT_VERSION,
                          uint8 filePositionSizeInBytes = 8);
    static JPQFile* LoadJPQPackage(std::string path);
   
};

#pragma GCC visibility pop
#endif
