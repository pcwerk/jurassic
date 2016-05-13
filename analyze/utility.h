// --*-c++-*--

#include <string>

#ifndef _UTILITY_H
#define _UTILITY_H

const std::string intToString(int x);
const std::string longToString(long x);
const std::string doubleToString(double x);

int toInteger(const std::string &str);
double toDouble(const std::string &str);
long toLong(const std::string &str);

#endif

