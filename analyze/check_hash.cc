// --*-c++-*--

#include <algorithm>
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <iostream>
#include <list>
#include <map>
#include <set>

#include "hash_table.h"

#define VERSION "0.0.5"

int main(int argc, char **argv)
{
  std::cout << "check_hash version " << VERSION << std::endl;
  if (argc < 5) {
    std::cout << "usage: " << argv[0] << " "
              << "<reference-file> <input-data-file> <unknown-file> <output-file>" 
	      << std::endl;
    exit(1);
  }
  
  int c = 1;
  std::string reference_filename = argv[c++];
  std::string input_data_filename = argv[c++];
  std::string output_unknown_filename = argv[c++];
  std::string out_filename = argv[c++];
  
  HashTable reference(reference_filename);
  
  std::set<std::string> input_data;
  std::set<std::string> output_data;
  std::set<std::string> unknown_hashes;
  
  int line_count = 0;
  
  {
    std::ifstream infile(input_data_filename);
    std::string line;
    
    while (std::getline(infile, line)) {
      std::istringstream iss(line);
      std::string key;
      
      if (!(iss >> key)) {
        break;
      }
      
      std::transform(key.begin(), key.end(), key.begin(), ::toupper);
      input_data.insert(key);
      line_count++;
    }
  }
  
  for (std::set<std::string>::iterator p = input_data.begin();
       p != input_data.end(); ++p) {
    if (! reference.hasCaseIgnore(*p)) {
      unknown_hashes.insert(*p);
    } else {
      output_data.insert(*p);
    }
  }
  
  // save results
  {
    std::ofstream out(out_filename);

    for (std::set<std::string>::iterator p = output_data.begin();
	 p != output_data.end(); ++p) {
      out << *p << std::endl;
    }

    out.close();
  }

  // save unknowns
  {
    std::ofstream unk(output_unknown_filename);

    for (std::set<std::string>::iterator p = unknown_hashes.begin();
	 p != unknown_hashes.end(); ++p) {
      unk << *p << std::endl;
    }

    unk.close();
  }

  std::cout << "reference file    " << reference_filename; 
  std::cout << " (" << reference.size() << ")" << std::endl;
  std::cout << "input data file   " << input_data_filename;
  std::cout << " (" << line_count << ")";
  std::cout << " (" << input_data.size() << ") " << std::endl;
  std::cout << "unknown out file  " << output_unknown_filename;
  std::cout << " (" << unknown_hashes.size() << ")" << std::endl;
  std::cout << "out file          " << out_filename;
  std::cout << " (" << output_data.size() << ")" << std::endl;

  return 0;
}
