#include <iostream>
#include <time.h>
#include "quadratic.h"
using namespace std;

int main() {
	float mya, myb, myc;      // values
	float root1, root2;       // roots

	cout << "Please enter the values for A, B, and C:\n";

	cout << "A = ";			 // get inputs a,b and c
	cin >> mya;

	cout << "B = ";
	cin >> myb;

	cout << "C = ";
	cin >> myc;

	int results = Quadratic(mya, myb, myc, &root1, &root2);  // results of the quadratic eqution, there can be 1 root, 2 roots, or a complex root.

	if (results == -1) 
	{
		cout << "The root is complex";
	}
	else if (root1 == root2)
	{
		cout << "There is only one root to the quadratic equation: \n";
		cout << "x = ";
		cout << root1;   // both root1 and root2 are the same so just output root1, but root2 could also be used
	}
	else
	{
		cout << "The roots of the quadratic equation are \n";
		cout << "x = ";
		cout << root1;
		cout << " or";
		cout << " x = ";
		cout << root2;
		cout << "\n";
	}
	return 0;
}