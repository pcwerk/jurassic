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

#define VERSION "0.0.6"

int main(int argc, char **argv)
{
  std::cout << "match_unknown version " << VERSION << std::endl;
  if (argc < 4) {
    std::cout << "usage: " << argv[0] << " "
              << "<unknown-hash> <hash-file-origin> <out-file>"
	      << std::endl;
    exit(1);
  }
  
  int c = 1;
  std::string unknown_hash_filename = argv[c++];
  std::string origin_hash_filename = argv[c++];
  std::string out_filename = argv[c++];
  
  HashTable origin_hash;
  origin_hash.initTwoColumns(origin_hash_filename);

  HashTable unknown_hash;
  unknown_hash.initOneColumn(unknown_hash_filename);

  std::ofstream out(out_filename);
  for (HashTable::Iterator p = unknown_hash.begin();
       p != unknown_hash.end(); ++p) {
     std::string h = p->first;
     if (origin_hash.hasCaseIgnore(h)) {
       out << h << " " << origin_hash.getCaseIgnore(h) << std::endl;
     }
  }
  out.close();

  return 0;
}
