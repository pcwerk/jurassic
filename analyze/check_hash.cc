// --*-c++-*--

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <iostream>
#include <list>


#include "hash_table.h"

int main(int argc, char **argv)
{
  if (argc < 4) {
    std::cout << "usage: " << argv[0] 
              << " [bad|good] <reference-file> <data-file>" << std::endl;
    exit(1);
  }

  std::string mode = argv[1];
  std::string reference_filename = argv[2];
  std::string data_filename = argv[3];

  // read reference file
  HashTable reference;
  reference.initOneColumn(reference_filename);
  
  // read data file
  std::list<std::string> data;
  {
    std::ifstream infile(data_filename);
    std::string line;
    
    while (std::getline(infile, line)) {
      std::istringstream iss(line);
      std::string key;
      if (!(iss >> key)) {
        break;
      }
      data.push_back(key);
    }
  }

  // only print bad ones
  if (mode == "good") {
    std::cout << "potentially bad hash" << std::endl;
    for (std::list<std::string>::iterator p = data.begin();
         p != data.end(); ++p) {
      if (! reference.hasCaseIgnore(*p)) {
        std::cout << *p << std::endl;
      }
    }
  } else {
    std::cout << "definitely bad hash" << std::endl;
    for (std::list<std::string>::iterator p = data.begin();
         p != data.end(); ++p) {
      if (reference.hasCaseIgnore(*p)) {
        std::cout << *p << std::endl;
      }
    }
  }
  
  return 0;
}
