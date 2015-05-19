//
//  JPQUtilities.h
//  JPQLib
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

#ifndef JPQLib_JPQUtilities_h
#define JPQLib_JPQUtilities_h

class JPQUtilities
{
private:
    
public:
    static bool ReservedFileName(std::string s)
    {
        char f = s[0];
        char l = s[s.length() - 1];
        if (f == '(' && l == ')')
            return true;
        return false;
    }
    
    static void CleanFilePath(std::string s)
    {
        std::replace(s.begin(), s.end(), '\\', '/');
        std::transform(s.begin(), s.end(), s.begin(), ::tolower);
        if (s.at(0) != '/')
        {
            s.insert(0, std::string("/"));
        }
    }
};

#endif
