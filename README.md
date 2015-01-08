# JPQ (Jared Package) Library

## Introduction

The JPQ Library is a C++ piece of software inspired by Blizzard Entertainment's MPQ file format. The JPQ library allows for the creation of very large data stores of files. JPQ is designed to be used in video games and high performance applications that require a faster alternative to that of a typical B-TREE log(n) based file lookup that is used by most file systems. Files that are inserted into a JPQ file format are indexed using a hash table for really fast ~O(1) lookup. When high performance applications, in particular games have to load in tons of resources from disk, a lot of times software applications will freeze or stay stuck on a loading bar while resources load from disk. The JPQ library is used to counteract this. Utilizing both spatial locality along with the fast lookup of the hash table, software is able to access files from disk considerably faster than that of an OS filesystem.

## Vision

This file format is relatively new and largely not usable in its current form. A lot of ideas for this software are being drafted, some highly likely ones to be included are.
 + File Encryption for Specified Files: It would be really nice to add encryption into this library in order to protect resources inside the file. The design is simple, known file formats will be compressed using the best compression ratio for the particular file format uploaded. Encryption will *only* be applied if the file is manually designated to be encrypted.
 + Public/Private Remote Encryption: A lot of games and software released today are large enough to where partial patches are shipped to clients/customers before the final patch is ready. The idea behind remote encryption is to use a private key to encrypt files in a JPQ, and then on a specified date a server can release a public key that will seamlessly decrypt the files located in the JPQ.
 + Remote Synchronization: The idea here is really simple. The JPQ can be designated to check with a server and auto update specified files if need be. An MD5 or SHA hash can be computed to check to see if files are corrupted or modified before the JPQ will release the file to the running program utilizing the library. This is important because it allows the software developer to prevent the execution or usability of modified contents inside of a JPQ.
 + Optimal Hash-Table: Since hashing is not always perfect, sometimes if a hash table is too small a lot of collisions can take place. Since our hash table is stored as a file it is required to use open adressing instead of chaining which is faster. Therefore whenever the developer is finished adding files into the JPQ, they are given the option to allow an optimizer to run that will search for the best hashing key. The developer will be able to specify how long they want the program to search for an efficient key before giving up and choosing the fastest one it has already found.
 + Much More: I have a lot of ideas in-store for this library. If you have any recommendations please create an issue on GitHub. Thanks!

## System Requirements (Not Fully Specified Yet)
 + Platform: OS X, Windows, Linux, or BSD
 + Processor: SSE2 Support

Please Note: The current JPQ system is only compatible with OS X as of this moment. Once we implement the required features specified above it'll be repackaged with cross platform CMake support.