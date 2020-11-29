#include<iostream>
#include <iomanip>

using namespace std;

int main(){
  cout << hex;
  cout << setw(2);
  cout << setfill('0');

  for(int i=0; i<8192; i++){
    if(i==5120){
      cout << "48" << endl;
    }else if(i==5121){
      cout << "12" << endl;
    } else if(i==5122){
      cout << "02" << endl;
    } else if(i==5123){
      cout << "24" << endl;
    } else if(i==5124){
      cout << "08" << endl;
    }else{
      cout << "00" << endl;
    }
  }
}
