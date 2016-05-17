// --*-c++-*--

#include <stdio.h>
#include <float.h>

#include <limits>
#include <climits>
#include <iostream>
#include <string>

#include "utility.h"

const std::string intToString(int x)
{
  char buffer[1024];
  sprintf(buffer, "%d", x);

  return std::string(buffer);
}

const std::string longToString(long x)
{
  char buffer[1024];
  sprintf(buffer, "%ld", x);

  return std::string(buffer);
}

const std::string doubleToString(double x)
{
  char buffer[1024];
  sprintf(buffer, "%g", x);

  return std::string(buffer);
}

int toInteger(const std::string &str)
{
  try {
    return atoi(str.c_str());
  } catch (int i) {
    std::cout << "exception caught: converting ["
              << str
              << "] to int is illegal" 
              << std::endl;
  }

  return -INT_MAX;
}

double toDouble(const std::string &str)
{
  try {
    return atof(str.c_str());
  } catch (int i) {
    std::cout << "exception caught: converting ["
              << str
              << "] to double is illegal" 
              << std::endl;
  }

  return -DBL_MAX;
}

long toLong(const std::string &str)
{
  try {
    return atol(str.c_str());
  } catch (int i) {
    std::cout << "exception caught: converting ["
              << str
              << "] to long is illegal" 
              << std::endl;
  }

  return -LONG_MAX;
}

