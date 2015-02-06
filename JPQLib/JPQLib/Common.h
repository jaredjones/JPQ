//
//  Common.h
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#ifndef JPQLib_Common_h
#define JPQLib_Common_h

#include <stdint.h>
#include <math.h>

typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;
typedef int8_t int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

static const bool JPQ_DEFAULT_OVERWRITEFILE = false;
static const uint32_t JPQ_DEFAULT_MAXFILES = 1024;
static const uint16_t JPQ_DEFAULT_VERSION = 1;
static const uint8_t JPQ_DEFAULT_FILEPOSITIONSIZEINBYTES = 4;
static const uint64_t JPQ_DEFAULT_FILEHASHINDEXSIZEINBYTES = 2147483648; //2^31 (Half of 32-bits)

static const uint8_t JPQ_HEADER_SIZE = 49; //MUST BE UPDATED MANUALLY WHEN HEADER SPEC CHANGES
static const char* JPQ_SIGNATURE = "JPQ\xff\x0a\x20";

#endif
