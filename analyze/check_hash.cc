// --*-c++-*--

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <iostream>
#include <list>

#include "hash_table.h"

#define VERSION "0.03"

int main(int argc, char **argv)
{
  std::cout << "check_hash version " << VERSION << std::endl;
  if (argc < 6) {
    std::cout << "usage: " << argv[0] << " "
              << "[bad|good] <reference> <data-file> <unknown> <output>" 
	      << std::endl;
    exit(1);
  }

  std::string mode = argv[1];
  std::string reference_filename = argv[2];
  std::string data_filename = argv[3];
  std::string unk_filename = argv[4];
  std::string out_filename = argv[5];
  int counter = 0;
  int unk_counter = 0;

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

  // only print bad ones
  if (mode == "good") {
    std::ofstream unk(unk_filename);
    std::ofstream good(out_filename);

    std::cout << "good file: " << out_filename << std::endl;
    for (std::list<std::string>::iterator p = data.begin();
         p != data.end(); ++p) {
      if (! reference.hasCaseIgnore(*p)) {
	unk << *p << std::endl;
        unk_counter++;
      } else {
	good << *p << std::endl;
        counter++;
      }
    }

    unk.close();
    good.close();

    std::cout << "good hashes found: " << counter << std::endl;
  }

  if (mode == "bad") {
    std::ofstream unk(unk_filename);
    std::ofstream bad(out_filename);

    std::cout << "bad file: " << out_filename << std::endl;

    for (std::list<std::string>::iterator p = data.begin();
         p != data.end(); ++p) {
      if (reference.hasCaseIgnore(*p)) {
	bad << *p << std::endl;
        counter++;
      } else {
	unk << *p << std::endl;
        unk_counter++;
      }
    }

    unk.close();
    bad.close();

    std::cout << "bad hashes found: " << counter << std::endl;
  }
  
  std::cout << "unkown file: " << unk_filename << std::endl;
  std::cout << "unknown hashes: " << unk_counter << std::endl;

  return 0;
}
