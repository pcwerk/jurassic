// --*-c++-*--

#include <algorithm> 
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>

#include "utility.h"
#include "hash_table.h"

HashTable::HashTable(const std::string &filename)
{
  initOneColumn(filename);
}

void HashTable::initOneColumn(std::string const &filename)
{
  std::ifstream infile(filename);
  std::string line;
  
  while (std::getline(infile, line)) {
#if 0
    std::istringstream iss(line);
#endif
    std::string key = line;
#if 0
    if (!(iss >> key)) {
      break;
    }
#endif
    std::transform(key.begin(), key.end(), key.begin(), ::toupper);
    pTable[key] = key;
  }
}

void HashTable::initTwoColumns(std::string const &filename)
{
  std::ifstream infile(filename);
  std::string line;
  
  while (std::getline(infile, line)) {
    std::istringstream iss(line);
    std::string key, value;
    if (!(iss >> key >> value)) {
      break;
    }

    std::transform(key.begin(), key.end(), key.begin(), ::toupper);
    pTable[key] = value;
  }
}

void HashTable::set(const std::string &key, const std::string &value)
{
  pTable[key] = value;
}

void HashTable::set(const std::string &key, const int value)
{
  pTable[key] = intToString(value);
}

void HashTable::set(const std::string &key, const long value)
{
  pTable[key] = longToString(value);
}

void HashTable::set(const std::string &key, const double value)
{
  pTable[key] = doubleToString(value);
}

const bool HashTable::has(const std::string &key)
{
  if (pTable.find(key) == pTable.end())
    return false;
  else
    return true;
}

const bool HashTable::hasCaseIgnore(const std::string &k)
{
  std::string key = k;
  std::transform(key.begin(), key.end(), key.begin(), ::toupper);

  if (pTable.find(key) == pTable.end())
    return false;
  else
    return true;
}

const std::string HashTable::get(const std::string &key)
{
  if (pTable.find(key) == pTable.end())
    return std::string("");
  else
    return pTable[key];
}

const std::string HashTable::getCaseIgnore(const std::string &k)
{
  std::string key = k;
  std::transform(key.begin(), key.end(), key.begin(), ::toupper);

  if (pTable.find(key) == pTable.end())
    return "";
  else
    return pTable[key];
}

const std::string HashTable::toString(const std::string spacing)
{
  std::ostringstream oss;
  
  for (std::unordered_map<std::string, std::string>::iterator
         p = pTable.begin(); p!= pTable.end(); ++p) {
    std::string key = p->first;
    std::string value = p->second;
    pTable[key] = value;
    oss << spacing << key << " " << value << "\n";
  }

  return oss.str();  
}

const int HashTable::size()
{
  return pTable.size();
}

HashTable::Iterator HashTable::begin()
{
  return pTable.begin();
}

HashTable::Iterator HashTable::end()
{
  return pTable.end();
}
