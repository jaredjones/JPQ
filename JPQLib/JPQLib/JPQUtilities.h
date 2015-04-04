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
};

#endif
