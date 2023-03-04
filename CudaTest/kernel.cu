
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <thread>
#include <vector>
#include <time.h>
#include <iostream>

cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);

__global__ void addKernel(int *c, const int *a, const int *b)
{
    int i = threadIdx.x;
    c[i] = a[i] + b[i];
}

void addArraysSingleThreadCPU(const int* a, const int* b, int* c, int size, double& time) 
{
    clock_t t = clock();
    for (int i = 0; i < size; ++i)
        c[i] = a[i] + b[i];
    t = clock() - t;
    time = (((double)t) / CLOCKS_PER_SEC) ;  // in seconds
}

void addArraysMultiThreadCPU(const int* a, const int* b, int* c, int i)
{
    c[i] = a[i] + b[i];
}

int main()
{
    const int arraySizeToPrint = 5;
    
    int arraySize = 0;
    std::cout << "Enter array size:\n" << std::endl;
    std::cin >> arraySize;
    while (arraySize > 0)
    {
        int* a = new int[arraySize];
        for (int i = 0; i < arraySize; ++i)
            a[i] = i + 1;
        int* b = new int[arraySize];
        for (int i = 0; i < arraySize; ++i)
            b[i] = (i + 1) * 10;
        int* cCUDA = new int[arraySize];
        int* cSingleThreadCPU = new int[arraySize];
        int* cMultiThreadCPU = new int[arraySize];
        for (int i = 0; i < arraySize; ++i)
            cCUDA[i] = cSingleThreadCPU[i] = cMultiThreadCPU[i] = 0;
        std::vector<std::thread> threads(arraySize);
        clock_t t;
        double time_taken = 0;

        // Add vectors in parallel.
        t = clock();
        cudaError_t cudaStatus = addWithCuda(cCUDA, a, b, arraySize);
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "addWithCuda failed!\n");
            //return 1;
        }
        t = clock() - t;
        time_taken = (((double)t) / CLOCKS_PER_SEC) ; // in seconds

        printf("\nCUDA took %f seconds: ", time_taken);
        for (int i = 0; i < arraySizeToPrint; ++i)
            printf("%d ", cCUDA[i]);

        //Add vectors in CPU Single thread
        addArraysSingleThreadCPU(a, b, cSingleThreadCPU, arraySize, time_taken);

        printf("\nCPU Single Thread took %f seconds: ", time_taken);
        for (int i = 0; i < arraySizeToPrint; ++i)
            printf("%d ", cSingleThreadCPU[i]);

        //Add vectors in CPU Multi thread

        //t = clock();
        //for (int i = 0; i < arraySize; ++i)
        //    threads[i] = std::thread(addArraysMultiThreadCPU, a, b, cMultiThreadCPU, i);
        //for (auto& th : threads) {
        //    th.join();
        //}
        //t = clock() - t;
        //time_taken = (((double)t) / CLOCKS_PER_SEC) ;  // in seconds

        //printf("\nCPU Multi Thread took %f seconds: ", time_taken);
        //for (int i = 0; i < arraySizeToPrint; ++i)
        //    printf("%d ", cMultiThreadCPU[i]);

        // cudaDeviceReset must be called before exiting in order for profiling and
        // tracing tools such as Nsight and Visual Profiler to show complete traces.
        cudaStatus = cudaDeviceReset();
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "cudaDeviceReset failed!\n");
            //return 1;
        }
        delete[] a;
        delete[] b;
        delete[] cCUDA;
        delete[] cSingleThreadCPU;
        delete[] cMultiThreadCPU;

        std::cout << "\n\nEnter array size:" << std::endl;
        std::cin >> arraySize;
    }

    return 0;
}

// Helper function for using CUDA to add vectors in parallel.
cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size)
{
    int *dev_a = 0;
    int *dev_b = 0;
    int *dev_c = 0;
    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy input vectors from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    // Launch a kernel on the GPU with one thread for each element.
    addKernel<<<1, size>>>(dev_c, dev_a, dev_b);

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }
    
    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_c);
    cudaFree(dev_a);
    cudaFree(dev_b);
    
    return cudaStatus;
}
