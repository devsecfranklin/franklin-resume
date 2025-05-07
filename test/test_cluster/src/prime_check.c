#include <mpi.h>
#include <iostream>
#include <cmath>

using namespace std;

bool isPrime(int num) {
    if (num <= 1) {
        return false;
    }
    if (num <= 3) {
        return true;
    }
    if (num % 2 == 0 || num % 3 == 0) {
        return false;
    }

    int i = 5;
    while (i * i <= num) {
        if (num % i == 0 || num % (i + 2) == 0) {
            return false;
        }
        i += 6;
    }

    return true;
}

int main(int argc, char** argv) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int num;
    if (rank == 0) {
        cout << "Enter a number to check for primality: ";
        cin >> num;
    }

    MPI_Bcast(&num, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int node;
    MPI_Comm_rank(MPI_COMM_WORLD, &node);
    //printf("Running on node%d\n", node);
    int start = rank * (num / size) + 1;
    int end = (rank + 1) * (num / size);
    printf("checking from %d to %d on node%d\n", start, end);

    bool isPrimeLocal = true;
    for (int i = start; i <= end; i++) {
        if (num % i == 0) {
            isPrimeLocal = false;
            break;
        }
    }

    bool isPrimeGlobal;
    MPI_Allreduce(&isPrimeLocal, &isPrimeGlobal, 1, MPI_C_BOOL, MPI_LAND, MPI_COMM_WORLD);

    if (rank == 0) {
        if (isPrimeGlobal) {
            cout << num << " is a prime number." << endl;
        } else {
            cout << num << " is not a prime number." << endl;
        }
    }

    MPI_Finalize();
    return 0;
}

/*

Explanation:

MPI Initialization: The code starts by initializing MPI and getting the rank of the current process and the total number of processes.
Number Input: The root process (rank 0) takes the number to be checked from the user.
Number Broadcast: The root process broadcasts the number to all other processes using MPI_Bcast.
Work Distribution: Each process calculates its range of numbers to check. The range is determined by dividing the number by the number of processes and assigning each process a portion.
Primality Check: Each process checks if the number is divisible by any number within its assigned range. If a divisor is found, the isPrimeLocal flag is set to false.
Global Reduction: The MPI_Allreduce function is used to combine the isPrimeLocal flags from all processes into a single isPrimeGlobal flag using the logical AND operation (MPI_LAND). This determines if the number is prime across all processes.
Result Output: The root process prints the final result based on the isPrimeGlobal flag.
MPI Finalization: The MPI environment is finalized.
Key Points:

Work Distribution: The work of checking divisibility is distributed among the processes, improving efficiency.
Global Reduction: The MPI_Allreduce function is used to efficiently combine the results from all processes.
Optimization: The primality check can be optimized by only checking divisibility up to the square root of the number.
Error Handling: Consider adding error handling for cases like invalid input or MPI errors.
This code effectively utilizes MPI to parallelize the primality check, making it suitable for cluster computing environments.


Sources and related content


*/
