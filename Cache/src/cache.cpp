#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cstdlib>
#include <bitset>
#include <ctime>
#include <cstdio>
#include <vector>

using namespace std;

int main(int argc, char *argv[]){
	string input = argv[1];
	string output = argv[2];

	ifstream fin;
	fin.open(input.c_str(), ios::in);
	ofstream fout;
	fout.open(output.c_str(), ios::out);

	if(!fin){
		cerr << "can't open input file" << endl;
		exit(1);
	}
	
	if(!fout){
		cerr << "can't open output file" << endl;
		exit(1);
	}

	int cache_size = 0, block_size = 0, associativity = 0, policy = 0;
	fin >> cache_size;
	fin >> block_size;
	fin >> associativity;
	fin >> policy;

	//cout << "cache size " << cache_size << endl;
	//cout << "block size " << block_size << endl;
	//cout << associativity << endl;
	//cout << "policy "  << policy << endl;


	int block_num;
	block_num = cache_size * 1024 / block_size;
	int temp = block_num;
	int index_num = 0;
	//cout << block_num << endl;

	while(temp != 1){
		temp = temp >> 1 ;
		++index_num;
	}
	int offset = 0;
	while(block_size != 1){
		block_size = block_size >> 1;
		++offset;
	}
	//cout << "index "  << index_num <<endl;
	//cout << "offset " << offset << endl;

	int set_num = 0, entry_num = 0;
	int tag_bit = 32 - index_num - offset;


	if(associativity == 0){ //DIRECTED MAP
		set_num = block_num;
		entry_num = 1;
	}
	else if(associativity == 1){ //FOUR WAY
		set_num = block_num / 4;
		entry_num = 4;
		index_num -= 2;
		tag_bit += 2;
	}
	else if(associativity == 2){ //FULL
		set_num = 1;
		entry_num = block_num;
		tag_bit += index_num;
		index_num = 0;
	}
	//cout << tag_bit << endl;
	//cout << set_num << endl;
	//cout << entry_num << endl;
	//cout << "inum " << index_num << endl;
	//cout << "offset " << offset << endl;


	int valid[set_num][entry_num];
	unsigned int tag[set_num][entry_num];
	int FIFO[set_num];
	int LRU[set_num][entry_num];
	int LRU_current[set_num];
	int LFU[set_num][entry_num];
	//int LRU_optimal[set_num][entry_num * 2];


	for(int i = 0;i < set_num;i++){
		LRU_current[i] = 0;
		FIFO[i] = -1;
		for(int j = 0;j < entry_num;j++){
			valid[i][j] = 0;
			tag[i][j] = 0;
			LRU[i][j] = -1;
			LFU[i][j] = 0;
			//LRU_optimal[i][j] = 0;
			//LRU_optimal[i][j+1] = 0;

		}
	}
	string str;
	int count = 0; 
	srand(time(NULL));

	while(fin >> str){
		count++;
		//cout << str << endl;
		unsigned int address;
		stringstream ss;
		ss << std::hex << str;
		ss >> address;
		//cout << "address " << std::hex << address << endl;
		unsigned int tag_value = address >> offset >> index_num;
		unsigned int index = ((unsigned int)(address << tag_bit)) >> tag_bit >> offset;
		//cout << "tag "<< tag_value << endl;
		//cout << "index " << std::dec << index << endl;
		
		for(int i = 0;i < entry_num;i++){
			//hit
			if(valid[index][i] && tag[index][i] == tag_value){
				//cout << "hit test\n";
				fout << -1 << endl;
				LRU_current[index]++;
				LRU[index][i] = LRU_current[index];
				//LRU_optimal[index][i] = LRU_current[index];
				LFU[index][i]++;
				break;
			}
			//miss & update
			else if(!valid[index][i]){
				//cout << "updates: " << i <<endl;
				//cout << count << endl;
				fout << -1 << endl;
				tag[index][i] = tag_value;
				valid[index][i] = 1;
				LRU_current[index]++;
				LRU[index][i] = LRU_current[index];
				FIFO[index] = ++FIFO[index] % entry_num;
				//LRU_optimal[index][i] = LRU_current[index];
				LFU[index][i]++;
				break;
			}
			//miss & replace
			else if(i == (entry_num -1)){
				int search = 0;
				if(entry_num == 1){
					//cout << "directed\n";
					search = 0;
				}
				else{
					if(policy == 0){
						//FIFO
						cout << "FIFO\n";
						search = FIFO[index];
						FIFO[index] = ++FIFO[index] % entry_num;
					}
					else if(policy == 1){
						//LRU
						//cout << "LRU\n";
						for(int k = 0;k < entry_num;k++){
							if(LRU[index][k] < LRU[index][search]){
							  search = k;
							  //cout << search;
							}
						}
						//cout << "search: " << search << endl;
						LRU[index][search] = ++LRU_current[index];
					}
					else if(policy == 2){
						//LFU
						//cout << "POLICY RANDOM\n";
						//search = rand() % entry_num;
						for(int k = 1; k < entry_num;k++){
							if(LFU[index][k] < LFU[index][search]){
								search = k;
							}
						}
						LFU[index][search]++;
					}
				}
				fout << tag[index][search] << endl;
				tag[index][search] = tag_value;
			}
		}
	}
	fin.close();
	fout.close();

	return 0;
}
