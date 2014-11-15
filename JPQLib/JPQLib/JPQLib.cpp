#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#include <fstream>

#include "JPQLib.h"
#include "JPQUtilities.h"

JPQLib::JPQLib()
{
    srand((int)time(0));
    /*int HASHSIZE = 1000000;
    
    uint64 hashSeed = 2389323456453591;
    
    const char *msg;
    uint64 hash;
    
    msg = "Sup";
    
    hash = SpookyHash::Hash64(msg, strlen((char *)msg), hashSeed);
    printf("Hash:%llu\n", hash);
    printf("Index:%llu\n", hash % HASHSIZE);*/
    
    //CreateJPQPackage("/Users/jared/Desktop/Test.JPQ", 4);
    PrintLocalVariables();
    LoadJPQPackage("/Users/jared/Desktop/Test.JPQ");
    AddFile("/Users/jared/Desktop/abc.txt", "\\SupWorld\\Images/LocalImages/abc.txt");
}

void JPQLib::AddFile(std::string localPath, std::string jpqIndexPath)
{
    FILE *newFile;
    FILE *jpqFile;
    if (!(newFile = fopen(localPath.c_str(), "rb")))
    {
        printf("Cannot read the file you wanted to insert into the JPQ!\n");
        return;
    }
    if (!(jpqFile = fopen(_filePath.c_str(), "r+b")))
    {
        printf("Cannot open the JPQFile for writing!\n");
        return;
    }
    
    fseek(newFile, 0, SEEK_END);
    uint64 fileSize = ftell(newFile);
    rewind(newFile);
    
    void *data = malloc(fileSize);
    fread(data, fileSize, 1, newFile);
    
    std::replace(jpqIndexPath.begin(), jpqIndexPath.end(), '\\', '/');
    std::transform(jpqIndexPath.begin(), jpqIndexPath.end(), jpqIndexPath.begin(), ::tolower);
    
    uint64 indexHash = SpookyHash::Hash64(jpqIndexPath.c_str(), jpqIndexPath.length(), _indexSeed);
    uint32 collisHash = SpookyHash::Hash32(jpqIndexPath.c_str(), jpqIndexPath.length(), _collisionSeed);
    
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
            fclose(newFile);
            fclose(jpqFile);
            return;
        }
        
        //Use linear probing (efficient?) to check if the next index is occupied
        //NOTE: Run performance tests to compare linear vs quadradic probing in the future!
        fseek(jpqFile, _hTBeginIndex + (((htFileIndex+i+1) % _maxNumberOfFiles) * (4 + _filePositionSizeInBytes)), SEEK_SET);
        fread(&currHashValue, 4, 1, jpqFile);
        fseek(jpqFile, -4, SEEK_CUR);
        
        //If we're at the last element in our hash table and our collission hash is still not NULL
        //then we can assume that the hash table is full!
        if (currHashValue != 0 && _maxNumberOfFiles == (i+1))
        {
            printf("Hash table is full! Insertion Exited!\n");
            fclose(newFile);
            fclose(jpqFile);
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
    
    fclose(newFile);
    fclose(jpqFile);
}

void JPQLib::LoadJPQPackage(std::string path)
{
    FILE *jpqFile;
    if (!(jpqFile = fopen(path.c_str(), "rb")))
    {
        printf("Cannot open the JPQFile!\n");
        return;
    }
    _filePath = path;
    
    int jpqSigLen = (int)strlen(JPQ_SIGNATURE);
    fseek(jpqFile, jpqSigLen, SEEK_SET);
    fread(&_fileVersion, 2, 1, jpqFile);
    fread(&_maxNumberOfFiles, 4, 1, jpqFile);
    fread(&_hTBeginIndex, 8, 1, jpqFile);
    fread(&_filePositionSizeInBytes, 1, 1, jpqFile);
    fread(&_indexSeed, 8, 1, jpqFile);
    fread(&_collisionSeed, 4, 1, jpqFile);
    fread(&_dataBlockIndex, 8, 1, jpqFile);
    fread(&_dataBlockEnd, 8, 1, jpqFile);
    
    fclose(jpqFile);
}

void JPQLib::CreateJPQPackage(std::string path, uint32 maxNumberOfFiles, uint16 version, uint8 filePositionSizeInBytes)
{
    _filePath = path;
    _fileVersion = version;
    _maxNumberOfFiles = maxNumberOfFiles;
    _filePositionSizeInBytes = filePositionSizeInBytes;
    
    FILE *file;
    if ((file = fopen(path.c_str(), "rb")))
    {
        fclose(file);
        printf("File already exists!\n");
        return;
    }
    
    file = fopen(path.c_str(), "w+b");
    if (!file)
    {
        printf("There was an error creating the file!");
        return;
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
    _indexSeed = seed64;
    _collisionSeed = seed32;
    fwrite(&seed64, 8, 1, file);
    fwrite(&seed32, 4, 1, file);
    
    //NOTE:: THE DATABLOCKINDEX AND DATABLOCKEND LOCATIONS **MUST** COINCIDE RIGHT BEFORE THE _hTBeginIndex
    //       OR ELSE THE JPQ PROGRAM WILL BREAK!!! THE DATABLOCKINDEX IS USED AS A PIVOT FOR MOVING AROUND
    //       THE HEADER FILE!
    //Writes an empty remaining header of 16-bytes, used for dataBlockIndex and dataBlockEnd Location
    for (int i = 0; i < 16; i++)
        fwrite(&a,1,1,file);
    
    //BEGIN HASHTABLE
    _hTBeginIndex = ftell(file);
    fseek(file, jpqSigLen + sizeof(version) + sizeof(maxNumberOfFiles), SEEK_SET);
    fwrite(&_hTBeginIndex, 8, 1, file);
    fseek(file, _hTBeginIndex, SEEK_SET);
    
    //fileIndexSizeInBytes (For Lots of Files): We need  n-bits as well so that we can store 2^n files.
    //filePositionSizeInBytes (For Big File Sizes): It is important to have m-bit pointers to file locations
    
    //Complete HashTable Size
    uint64 htSize = maxNumberOfFiles * (/*fileIndexSizeInBytes + */4 + filePositionSizeInBytes);
    
    //File up file with the space required for the HashTable
    for (uint64 i = 0; i < htSize; i++)
        fwrite(&a, 1, 1, file);
    
    _dataBlockIndex = ftell(file);
    //Go to beginning of hashtable - 16 to get to where we need to write our 8 bytes for the data block index
    fseek(file, _hTBeginIndex - 16, SEEK_SET);
    fwrite(&_dataBlockIndex, 8, 1, file);
    fseek(file, _dataBlockIndex, SEEK_SET);
    
    _dataBlockEnd = ftell(file);
    fseek(file, _hTBeginIndex - 8, SEEK_SET);
    fwrite(&_dataBlockEnd, 8, 1, file);
    fseek(file, _dataBlockEnd, SEEK_SET);
    
    fclose(file);
}

void JPQLib::PrintLocalVariables()
{
    printf("_filePath:%s\n", _filePath.c_str());
    printf("_maxNumberOfFiles:%u\n", _maxNumberOfFiles);
    printf("_filePositionSizeInByte:%d\n",_filePositionSizeInBytes);
    printf("_indexSeed:%llu\n",_indexSeed);
    printf("_collisionSeed:%u\n",_collisionSeed);
    printf("_hTBeginIndex:%llu\n",_hTBeginIndex);
    printf("_dataBlockIndex:%llu\n",_dataBlockIndex);
    printf("_dataBlockEnd:%llu\n",_dataBlockEnd);
    
}