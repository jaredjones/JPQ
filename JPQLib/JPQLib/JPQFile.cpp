//
//  JPQFile.cpp
//  JPQLib
//
//  Created by Jared Jones on 11/28/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#include <stdio.h>

#include "JPQFile.h"
#include "JPQUtilities.h"
#include "Common.h"

void JPQFile::Reopen()
{
    Close();
    if (_filePath.empty())
    {
        printf("ERROR: File path is empty!\n");
        return;
    }
    
    if (!(_jpqFile = fopen(_filePath.c_str(), "r+")))
    {
        printf("File failed to open for writing/reading!\n");
        return;
    }
    //TODO: Rescan file after opening, at the moment we better hope nothing has changed.
}

void JPQFile::Close()
{
    if (_jpqFile)
    {
        fclose(_jpqFile);
        _jpqFile = nullptr;
    }
}

void JPQFile::Clear()
{
    Close();
    _jpqFile = nullptr;
    _filePath = std::string();
    _fileVersion = 0;
    _maxNumberOfFiles = 0;
    _filePositionSizeInBytes = 0;
    _indexSeed = 0;
    _collisionSeed = 0;
    _hTBeginIndex = 0;
    _dataBlockIndex = 0;
    _dataBlockEnd = 0;
    _errorCode = 0;
}

void JPQFile::AddFile(std::string localFilePath, std::string jpqFilePath, bool addToDir)
{
    //Lambda for cleaning up common memory that was malloc'd
    auto cleanUpMemory = [](FILE **f1)
    {
        fclose(*f1);
        *f1 = nullptr;
        f1 = nullptr;
    };
  
    if (_jpqFile == nullptr)
    {
        printf("You are attempting to insert a file into a JPQ that does not have a JPQ file reference!\n");
        return;
    }
    
    if (JPQUtilities::ReservedFileName(jpqFilePath))
    {
        printf("The filename/path you've chosen is either invalid or reserved by the JPQ file system:%s", jpqFilePath.c_str());
        return;
    }
    
    FILE *newFile;
    if (!(newFile = fopen(localFilePath.c_str(), "rb")))
    {
        cleanUpMemory(&newFile);
        printf("Cannot read the file you wanted to insert into the JPQ!\n");
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
    
    printf("Number of Elements in Table:%llu\n", GetNumberOfFiles());
    
    fseek(_jpqFile,
          _hTBeginIndex + (htFileIndex * (JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES + _filePositionSizeInBytes)),
          SEEK_SET);
    
    //Get the current hash value at this index
    uint32 currHashValue;
    fread(&currHashValue, JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, 1, _jpqFile);
    fseek(_jpqFile, -JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, SEEK_CUR);
    
    //If there is data at this value then the space is occupied.
    //Iterate through hash table till we find an available spot
    for (int i = 0; currHashValue != 0; i++)
    {
        //Check to see if data is a file that already exists.
        if (currHashValue == collisHash)
        {
            printf("File already exists, this should replace but at the moment writing won't happen!\n");
            cleanUpMemory(&newFile);
            return;
        }
        
        //Use linear probing (efficient?) to check if the next index is occupied
        //NOTE: Run performance tests to compare linear vs quadradic probing in the future!
        fseek(_jpqFile,
              _hTBeginIndex + (((htFileIndex+i+1) % _maxNumberOfFiles) * (JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES + _filePositionSizeInBytes)),
              SEEK_SET);
        fread(&currHashValue, JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, 1, _jpqFile);
        fseek(_jpqFile, -JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, SEEK_CUR);
        
        //If we're at the last element in our hash table and our collission hash is still not NULL
        //then we can assume that the hash table is full!
        if (currHashValue != 0 && _maxNumberOfFiles == (i+1))
        {
            printf("Hash table is full! Insertion Exited!\n");
            cleanUpMemory(&newFile);
            return;
        }
        
        if (currHashValue == 0)
        {
            htFileIndex = (htFileIndex+i+1) % _maxNumberOfFiles;
            break;
        }
    }
    
    printf("HT Written at Index:%llu\n", htFileIndex);
    
    fwrite(&collisHash, JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, 1, _jpqFile);
    //Write the pointer to where the data begins
    printf("DATA AT: %llu\n", _dataBlockEnd);
    fwrite(&_dataBlockEnd, _filePositionSizeInBytes, 1, _jpqFile);
    
    //Use the _dataBlockEnd to store the next file!
    fseek(_jpqFile, _dataBlockEnd, SEEK_SET);
    
    //Write Space for ArchiveSize, Origional Size, and Flags
    //20 bytes total
    char a = '\x00';
    fwrite(&fileSize, sizeof(uint64), 1, _jpqFile);  // Archive Size
    fwrite(&fileSize, sizeof(uint64), 1, _jpqFile);  // Original Size
    fwrite(&a, sizeof(uint32), 1, _jpqFile);         // File Mask
    
    //Write file contents
    fwrite(data, fileSize, 1, _jpqFile);
    
    //Update _dataBlockEnd pointer
    _dataBlockEnd = ftell(_jpqFile);
    printf("DBEND:%llu\n", _dataBlockEnd);
    printf("HTBEG:%llu\n", _hTBeginIndex);
    fseek(_jpqFile, _hTBeginIndex-8, SEEK_SET);
    fwrite(&_dataBlockEnd, 8, 1, _jpqFile);
    fflush(_jpqFile);
    free(data);
    data = nullptr;
    
    cleanUpMemory(&newFile);
    _errorCode = (uint32)JPQFileError::NO_ERROR;
}

//TODO: This function should be thread safe.
void* JPQFile::LoadFile(std::string jpqFilePath, uint64 *fileSize)
{
    if (_jpqFile == nullptr)
    {
        printf("You are attempting to insert a file into a JPQ that does not have a JPQ file reference!\n");
        return nullptr;
    }
    
    std::replace(jpqFilePath.begin(), jpqFilePath.end(), '\\', '/');
    std::transform(jpqFilePath.begin(), jpqFilePath.end(), jpqFilePath.begin(), ::tolower);
    
    uint64 indexHash = SpookyHash::Hash64(jpqFilePath.c_str(), jpqFilePath.length(), _indexSeed);
    uint32 collisHash = SpookyHash::Hash32(jpqFilePath.c_str(), jpqFilePath.length(), _collisionSeed);
    
    uint64 htFileIndex = indexHash % _maxNumberOfFiles;
    fseek(_jpqFile,
          _hTBeginIndex + (htFileIndex * (JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES + _filePositionSizeInBytes)),
          SEEK_SET);
    
    uint32 currHashValue;
    void *file = nullptr;
    
    do
    {
        //Read currentHashValue into stack memory
        fread(&currHashValue, JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, 1, _jpqFile);
        
        if (currHashValue == 0)
        {
            _errorCode = (uint32)JPQFileError::JPQ_FILE_NOT_FOUND;
            printf("File At:\"%s\" does not exist in the archive.\n", jpqFilePath.c_str());
            return nullptr;
        }
        
        //Load File
        if (currHashValue == collisHash)
        {
            uint64 filePosition;
            uint64 archiveSize;
            uint64 originalSize;
            uint32 archiveMask;
            
            fread(&filePosition, JPQ_DEFAULT_FILE_POSITION_SIZE_IN_BYTES, 1, _jpqFile);
            fseek(_jpqFile, filePosition, SEEK_SET);
            fread(&archiveSize, sizeof(archiveSize), 1, _jpqFile);
            fread(&originalSize, sizeof(originalSize), 1, _jpqFile);
            fread(&archiveMask, sizeof(archiveMask), 1, _jpqFile);
            
            file = malloc(archiveSize);
            fread(file, archiveSize, 1, _jpqFile);
            *fileSize = archiveSize;
            return file;
        }
        
        //Unwind last read position
        fseek(_jpqFile, -JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES, SEEK_CUR);
        
        //Check for next currHashValue
        fseek(_jpqFile,
              _hTBeginIndex + ((++htFileIndex) % _maxNumberOfFiles) * (JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES + _filePositionSizeInBytes),
              SEEK_SET);
        
    }
    while (currHashValue != collisHash);
    
    return nullptr;
}

uint64 JPQFile::GetNumberOfFiles()
{
    if (_jpqFile == nullptr)
    {
        _errorCode = (uint32)JPQFileError::JPQ_FILE_NULL;
        return 0;
    }
    
    uint64 fileCounter = 0;
    for (int i = 0; i < _maxNumberOfFiles; i++)
    {
        fseek(_jpqFile,
              _hTBeginIndex + (i * (JPQ_DEFAULT_FILE_COLLISION_SIZE_IN_BYTES + _filePositionSizeInBytes)),
              SEEK_SET);
        uint32 collisValue;
        fread(&collisValue, 4, 1, _jpqFile);
        fseek(_jpqFile, -4, SEEK_CUR);
        printf("Exist[%u]:%u\n", i, collisValue);
        if (collisValue != 0)
            ++fileCounter;
    }
    return fileCounter;
}

void JPQFile::DisplayFileVariables()
{
    printf("#################################\n");
    printf("####DISPLAYING FILE VARIABLES####\n");
    printf("#################################\n");
    printf("_filePath:%s\n", _filePath.c_str());
    printf("_maxNumberOfFiles:%u\n", _maxNumberOfFiles);
    printf("_filePositionSizeInByte:%d\n",_filePositionSizeInBytes);
    printf("_indexSeed:%llu\n",_indexSeed);
    printf("_collisionSeed:%u\n",_collisionSeed);
    printf("_hTBeginIndex:%llu\n",_hTBeginIndex);
    printf("_dataBlockIndex:%llu\n",_dataBlockIndex);
    printf("_dataBlockEnd:%llu\n",_dataBlockEnd);
    printf("##################################\n");
    printf("####DISPLAYING CLASS VARIABLES####\n");
    printf("##################################\n");
    printf("_errorCode:%u\n", _errorCode);
    printf("\n");
}

uint32 JPQFile::GetErrorCode()
{
    return _errorCode;
}
