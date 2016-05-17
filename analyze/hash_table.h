// --*-c++-*--

#include <unordered_map>

#ifndef _HASH_TABLE_H
#define _HASH_TABLE_H

class HashTable {
public:
  HashTable() { };

public:
  void set(const std::string &key, const std::string &value);
  void set(const std::string &key, const int value);
  void set(const std::string &key, const long value);  
  void set(const std::string &key, const double value);

  const bool has(const std::string &key);
  const bool hasCaseIgnore(const std::string &key);
  const std::string get(const std::string &key);
  const std::string toString(const std::string spacing = "");
  const int size();

  void initOneColumn(const std::string &filename);
  void initTwoColumns(const std::string &filename);

private:
  std::unordered_map<std::string, std::string> pTable;
};

#endif
