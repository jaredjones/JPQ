//
//  Common.h
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#ifndef JPQLib_Common_h
#define JPQLib_Common_h

#include "SpookyV2.h"

enum class JPQFileError : uint32
{
    NO_ERROR            = 0x0,
    UNKOWN_ERROR        = 0x1,
    ALREADY_EXISTS      = 0x2,
    WRITE_ACCESS_DENIED = 0x4,
    READ_ACCESS_DENIED  = 0x8,
};

static const bool JPQ_DEFAULT_OVERWRITEFILE = false;
static const uint32_t JPQ_DEFAULT_MAXFILES = 1024;
static const uint16_t JPQ_DEFAULT_VERSION = 1;
static const uint8_t JPQ_DEFAULT_FILEPOSITIONSIZEINBYTES = 8;

static const char* JPQ_SIGNATURE = "JPQ\xff\x0a\x20";

#endif
