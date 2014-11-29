//
//  JPQLip.cpp
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "JPQLib.h"
#include "JPQFile.h"
#include "JPQUtilities.h"

 JPQFile* JPQLib::CreateJPQPackage(std::string localFilePath, uint32 maxNumberOfFiles, uint16 version, uint8 filePositionSizeInBytes)
{
    srand((unsigned int)time(0));
    JPQFile *newFile = new JPQFile();    
    
    newFile->_filePath = localFilePath;
    newFile->_fileVersion = version;
    newFile->_maxNumberOfFiles = maxNumberOfFiles;
    newFile->_filePositionSizeInBytes = filePositionSizeInBytes;
    
    FILE *file;
    if ((file = fopen(localFilePath.c_str(), "rb")))
    {
        fclose(file);
        printf("File already exists!\n");
        return nullptr;
    }
    
    file = fopen(localFilePath.c_str(), "w+b");
    if (!file)
    {
        printf("There was an error creating the file!");
        return nullptr;
    }
    
    int jpqSigLen = (int)strlen(JPQ_SIGNATURE);
    fwrite(JPQ_SIGNATURE, 1, jpqSigLen, file);
    
    //BEGIN HEADER (34 byte header)
    fwrite(&version, 2, 1, file);
    fwrite(&maxNumberOfFiles, 4, 1, file);
    
    char a = '\x00';
    
    //Creates 8 bytes of room for HashTableIndex
    for (int i = 0; i < 8; i++)
        fwrite(&a,1,1,file);
    
    //Store the filePositionSize
    fwrite(&filePositionSizeInBytes, 1, 1, file);
    
    //Generate 64-bit seed for hashing file paths and store it in the package.
    //Generate 32-bit seed for storing keys for collission prevention
    uint64 seed64 = ((unsigned long long)rand() << 32) + rand();
    uint32 seed32 = rand();
    newFile->_indexSeed = seed64;
    newFile->_collisionSeed = seed32;
    fwrite(&seed64, 8, 1, file);
    fwrite(&seed32, 4, 1, file);
    
    //NOTE:: THE DATABLOCKINDEX AND DATABLOCKEND LOCATIONS **MUST** COINCIDE RIGHT BEFORE THE _hTBeginIndex
    //       OR ELSE THE JPQ PROGRAM WILL BREAK!!! THE DATABLOCKINDEX IS USED AS A PIVOT FOR MOVING AROUND
    //       THE HEADER FILE!
    //Writes an empty remaining header of 16-bytes, used for dataBlockIndex and dataBlockEnd Location
    for (int i = 0; i < 16; i++)
        fwrite(&a,1,1,file);
    
    //BEGIN HASHTABLE
    newFile->_hTBeginIndex = ftell(file);
    fseek(file, jpqSigLen + sizeof(version) + sizeof(maxNumberOfFiles), SEEK_SET);
    fwrite(&newFile->_hTBeginIndex, 8, 1, file);
    fseek(file, newFile->_hTBeginIndex, SEEK_SET);
    
    //fileIndexSizeInBytes (For Lots of Files): We need  n-bits as well so that we can store 2^n files.
    //filePositionSizeInBytes (For Big File Sizes): It is important to have m-bit pointers to file locations
    
    //Complete HashTable Size
    uint64 htSize = maxNumberOfFiles * (/*fileIndexSizeInBytes + */4 + filePositionSizeInBytes);
    
    //File up file with the space required for the HashTable
    for (uint64 i = 0; i < htSize; i++)
        fwrite(&a, 1, 1, file);
    
    newFile->_dataBlockIndex = ftell(file);
    //Go to beginning of hashtable - 16 to get to where we need to write our 8 bytes for the data block index
    fseek(file, newFile->_hTBeginIndex - 16, SEEK_SET);
    fwrite(&newFile->_dataBlockIndex, 8, 1, file);
    fseek(file, newFile->_dataBlockIndex, SEEK_SET);
    
    newFile->_dataBlockEnd = ftell(file);
    fseek(file, newFile->_hTBeginIndex - 8, SEEK_SET);
    fwrite(&newFile->_dataBlockEnd, 8, 1, file);
    fseek(file, newFile->_dataBlockEnd, SEEK_SET);
    
    fclose(file);
    return newFile;
}

JPQFile* JPQLib::LoadJPQPackage(std::string localFilePath)
{
    JPQFile *loadedFile = new JPQFile();
    
    FILE *jpqFile;
    if (!(jpqFile = fopen(localFilePath.c_str(), "rb")))
    {
        printf("Cannot open the JPQFile!\n");
        return nullptr;
    }
    loadedFile->_filePath = localFilePath;
    
    int jpqSigLen = (int)strlen(JPQ_SIGNATURE);
    fseek(jpqFile, jpqSigLen, SEEK_SET);
    fread(&loadedFile->_fileVersion, 2, 1, jpqFile);
    fread(&loadedFile->_maxNumberOfFiles, 4, 1, jpqFile);
    fread(&loadedFile->_hTBeginIndex, 8, 1, jpqFile);
    fread(&loadedFile->_filePositionSizeInBytes, 1, 1, jpqFile);
    fread(&loadedFile->_indexSeed, 8, 1, jpqFile);
    fread(&loadedFile->_collisionSeed, 4, 1, jpqFile);
    fread(&loadedFile->_dataBlockIndex, 8, 1, jpqFile);
    fread(&loadedFile->_dataBlockEnd, 8, 1, jpqFile);
    
    fclose(jpqFile);
    return loadedFile;
}

