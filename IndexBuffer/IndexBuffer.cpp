// IndexBuffer.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>


/*


Table is:

       (0)  (1)  (2)  (3)  (4)

   (0)  1----2----3----4----5
        |    |    |    |    |
        |    |    |    |    |
   (1)  6----7----8----9----10
        |    |    |    |    |
        |    |    |    |    |
   (2)  11---12---13---14---15
        |    |    |    |    |
        |    |    |    |    |
   (3)  16---17---18---19---20
        |    |    |    |    |
        |    |    |    |    |
   (4)  21---22---23---24---25


Results should be:

    [
    1,  6,  2,  7,  3, 8,   4,  9,  5, 10,
    10, 6,
    6,  11, 7,  12, 8, 13,  9,  14, 10, 15,
    15, 11,
    11, 16, 12, 17, 13, 18, 14, 19, 15, 20,
    20, 16,
    16, 21, 17, 22, 18, 23, 19, 24, 20, 25
    ]

Which is:

    [ (0,0) , (1,0) , (0,1) , (1,1) , (0,2) , (1,2) , (0,3) , (1,3) , (0,4) , (1,4) ,
      (1,4) , (1,0) ,
      (1,0) , (2,0) , (1,1) , (2,1) , (1,2) , (2,2) , (1,3) , (2,3) , (1,4) , (2,4) ,
      (2,4) , (2,0)
      (2,0) , (3,0) , (2,1) , (3,1) , (2,2) , (3,2) , (2,3) , (3,3) , (2,4) , (3,4) ,
      (3,4) , (3,0) ,
      (3,0) , (4,0) , (3,1) , (4,1) , (3,2) , (4,2) , (3,3) , (4,3) , (3,4) , (4,4) ]

*/
struct Point
{
    char i;
    char j;

    void Print()
    {
        printf("(%d,%d) , ", i, j);
    }
};

struct Data
{
    char x;
    char y;
    char x;
};

void CreateIndexBuffer(int rows, int cols, Point*& arr_result, int& size)
{
    int index = 0;
    size = rows * cols * 2 + (rows - 1) * 2;
    arr_result = new Point[size];

    for (int i = 0; i < rows - 1; ++i) // No need for last row
    {
        for (int j = 0; j < cols; ++j)
        {
            arr_result[index].i = i;
            arr_result[index].j = j;

            arr_result[index].Print();

            index++;

            arr_result[index].i = i + 1;
            arr_result[index].j = j;

            arr_result[index].Print();

            index++;
        }

        printf("\n");
        
        if (i + 1 == rows - 1)
            break;

        arr_result[index].i = i + 1;
        arr_result[index].j = cols - 1;
        arr_result[index].Print();

        index++;

        arr_result[index].i = i + 1;
        arr_result[index].j = 0;
        arr_result[index].Print();

        printf("\n");
        index++;
    }
}

int main()
{
    std::cout << "Hello World!\n";
    std::cout << "Enter a number:\n";

    int n;
    std::cin >> n;
    Point* points = nullptr;
    int size = 0;
    CreateIndexBuffer(n, n, points, size);
    std::cout << "\ndone!\n";
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
