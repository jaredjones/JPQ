//
//  JPQFile.cpp
//  JPQLib
//
//  Created by Jared Jones on 11/28/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#include <stdlib.h>
#include "JPQFile.h"
#include "Common.h"

void JPQFile::AddFile(std::string localFilePath, std::string jpqFilePath)
{
    auto cleanUpMemory = [](FILE *f1, FILE *f2)
    {
        fclose(f1);
        fclose(f2);
        f1 = nullptr;
        f2 = nullptr;
    };
    
    FILE *newFile;
    FILE *jpqFile;
    if (!(newFile = fopen(localFilePath.c_str(), "rb")))
    {
        cleanUpMemory(newFile, jpqFile);
        printf("Cannot read the file you wanted to insert into the JPQ!\n");
        return;
    }
    if (!(jpqFile = fopen(_filePath.c_str(), "r+b")))
    {
        cleanUpMemory(newFile, jpqFile);
        printf("Cannot open the JPQFile for writing!\n");
        return;
    }
    
    fseek(newFile, 0, SEEK_END);
    uint64 fileSize = ftell(newFile);
    rewind(newFile);
    
    void *data = malloc(fileSize);
    fread(data, fileSize, 1, newFile);
    
    std::replace(jpqFilePath.begin(), jpqFilePath.end(), '\\', '/');
    std::transform(jpqFilePath.begin(), jpqFilePath.end(), jpqFilePath.begin(), ::tolower);
    
    uint64 indexHash = SpookyHash::Hash64(jpqFilePath.c_str(), jpqFilePath.length(), _indexSeed);
    uint32 collisHash = SpookyHash::Hash32(jpqFilePath.c_str(), jpqFilePath.length(), _collisionSeed);
    
    uint64 htFileIndex = indexHash % _maxNumberOfFiles;
    
    printf("_hdFileIndex:%llu\n", htFileIndex);
    
    //Get # of files by iterating through the table.
    uint64 fileCounter = 0;
    for (int i = 0; i < _maxNumberOfFiles; i++)
    {
        fseek(jpqFile, _hTBeginIndex + (i * (4 + _filePositionSizeInBytes)), SEEK_SET);
        uint32 collisValue;
        fread(&collisValue, 4, 1, jpqFile);
        fseek(jpqFile, -4, SEEK_CUR);
        printf("Exist[%u]:%u\n", i, collisValue);
        if (collisValue != 0)
            ++fileCounter;
    }
    
    printf("Number of Elements in Table:%llu\n", fileCounter);
    
    fseek(jpqFile, _hTBeginIndex + (htFileIndex * (4 + _filePositionSizeInBytes)), SEEK_SET);
    
    //Get the current hash value at this index
    uint32 currHashValue;
    fread(&currHashValue, 4, 1, jpqFile);
    fseek(jpqFile, -4, SEEK_CUR);
    
    //If there is data at this value then the space is occupied.
    //Iterate through hash table till we find an available spot
    for (int i = 0; currHashValue != 0; i++)
    {
        //Check to see if data is a file that already exists.
        if (currHashValue == collisHash)
        {
            printf("File already exists, this should replace but at the moment writing won't happen!\n");
            cleanUpMemory(newFile, jpqFile);
            return;
        }
        
        //Use linear probing (efficient?) to check if the next index is occupied
        //NOTE: Run performance tests to compare linear vs quadradic probing in the future!
        fseek(jpqFile, _hTBeginIndex + (((htFileIndex+i+1) % _maxNumberOfFiles) * (JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES + _filePositionSizeInBytes)), SEEK_SET);
        fread(&currHashValue, 4, 1, jpqFile);
        fseek(jpqFile, -4, SEEK_CUR);
        
        //If we're at the last element in our hash table and our collission hash is still not NULL
        //then we can assume that the hash table is full!
        if (currHashValue != 0 && _maxNumberOfFiles == (i+1))
        {
            printf("Hash table is full! Insertion Exited!\n");
            cleanUpMemory(newFile, jpqFile);
            return;
        }
        
        if (currHashValue == 0)
            htFileIndex = (htFileIndex+i+1) % _maxNumberOfFiles;
    }
    
    printf("HT Written at Index:%llu\n", htFileIndex);
    
    fwrite(&collisHash, 4, 1, jpqFile);
    //Write the pointer to where the data begins
    fwrite(&_dataBlockEnd, _filePositionSizeInBytes, 1, jpqFile);
    
    //Use the _dataBlockEnd to store the next file!
    fseek(jpqFile, _dataBlockEnd, SEEK_SET);
    fwrite(data, fileSize, 1, jpqFile);
    
    //Update _dataBlockEnd pointer
    _dataBlockEnd = ftell(jpqFile);
    fseek(jpqFile, _hTBeginIndex-8, SEEK_SET);
    fwrite(&_dataBlockEnd, 8, 1, jpqFile);
    
    free(data);
    data = nullptr;
    
    cleanUpMemory(newFile, jpqFile);
    _errorCode = (uint32)JPQFileError::NO_ERROR;
}

void JPQFile::DisplayFileVariables()
{
    printf("####DISPLAYING FILE VARIABLES####\n");
    printf("_filePath:%s\n", _filePath.c_str());
    printf("_maxNumberOfFiles:%u\n", _maxNumberOfFiles);
    printf("_filePositionSizeInByte:%d\n",_filePositionSizeInBytes);
    printf("_indexSeed:%llu\n",_indexSeed);
    printf("_collisionSeed:%u\n",_collisionSeed);
    printf("_hTBeginIndex:%llu\n",_hTBeginIndex);
    printf("_dataBlockIndex:%llu\n",_dataBlockIndex);
    printf("_dataBlockEnd:%llu\n",_dataBlockEnd);
    printf("####DISPLAYING CLASS VARIABLES####\n");
    printf("_errorCode:%u", _errorCode);
    
}

uint32 JPQFile::GetErrorCode()
{
    return _errorCode;
}
