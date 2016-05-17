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
              << " [bad|good] <reference-file> <data-file>" 
	      << std::endl;
    exit(1);
  }

  std::string mode = argv[1];
  std::string reference_filename = argv[2];
  std::string data_filename = argv[3];
  std::string good_filename = data_filename + ".good";
  std::string bad_filename = data_filename + ".bad";
  std::string unk_filename = data_filename + ".unknown";

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
  std::cout << "reference count " << reference.size() << std::endl;
  std::cout << "data count " << data.size() << std::endl;
  std::cout << "unkown file: " << unk_filename << std::endl;

  // only print bad ones
  if (mode == "good") {
    std::ofstream unk(unk_filename);
    std::ofstream good(good_filename);

    std::cout << "good file: " << good_filename << std::endl;
    std::cout << "potentially bad hash" << std::endl;
    std::cout << "----- " << std::endl;
    for (std::list<std::string>::iterator p = data.begin();
         p != data.end(); ++p) {
      if (! reference.hasCaseIgnore(*p)) {
        std::cout << *p << std::endl;
	unk << *p << std::endl;
      } else {
	good << *p << std::endl;
      }
    }

    unk.close();
    good.close();
  }

  if (mode == "bad") {
    std::ofstream unk(unk_filename);
    std::ofstream bad(bad_filename);

    std::cout << "bad file: " << bad_filename << std::endl;
    std::cout << "definitely bad hash" << std::endl;
    std::cout << "----- " << std::endl;

    for (std::list<std::string>::iterator p = data.begin();
         p != data.end(); ++p) {
      if (reference.hasCaseIgnore(*p)) {
        std::cout << *p << std::endl;
	bad << *p << std::endl;
      } else {
	unk << *p << std::endl;
      }
    }

    unk.close();
    bad.close();
  }
  
  return 0;
}
