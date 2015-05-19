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
    
    static void CleanFilePath(std::string *s)
    {
        std::replace(s->begin(), s->end(), '\\', '/');
        std::transform(s->begin(), s->end(), s->begin(), ::tolower);
        if (s->at(0) != '/')
        {
            s->insert(0, std::string("/"));
        }
    }
    
    static std::string FileToPath(std::string file)
    {
        uint64 marker = 0;
        for (uint64 i = 0; i < file.length(); i++)
        {
            if (file.at(i) == '/')
                marker = i;
        }
        
        std::string s = file.substr(0, marker + 1);
        return s;
    }
};

#endif
