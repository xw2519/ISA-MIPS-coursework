#include<iostream>
#include<iomanip>

using namespace std;

int main(){
  cout << hex;
  cout << setw(2);
  cout << setfill('0');

  for(int i=0; i<8192; i++){    // Currently this just generates one program
    if(i==8){
      cout << "21" << endl;
    }else if(i==9){
      cout << "10" << endl;
    } else if(i==10){
      cout << "1F" << endl;
    } else if(i==12){
      cout << "08" << endl;
    }else if(i==5120){
      cout << "08" << endl;
    } else if(i==5122){
      cout << "08" << endl;
    } else if(i==5123){
      cout << "24" << endl;
    } else if(i==5124){
      cout << "21" << endl;
    }else if(i==5125){
      cout << "81" << endl;
    }else if(i==5128){
      cout << "09" << endl;
    }else if(i==5131){
      cout << "01" << endl;
    }else{
      cout << "00" << endl;
    }
  }
}
