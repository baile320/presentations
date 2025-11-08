#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/resource.h>
#include <cblas.h> // Standard header, both ATLAS and OpenBLAS provide this

// --- Conditional Include for OpenBLAS ---
// This section will only be included if we compile with -DUSE_OPENBLAS
#ifdef USE_OPENBLAS
  #include <openblas_config.h> // OpenBLAS-specific header
#endif
// --- End Conditional Include ---

void print_mem_usage() {
    struct rusage usage;
    getrusage(RUSAGE_SELF, &usage);
    printf("Memory Usage (max resident set size): %ld KB\n", usage.ru_maxrss);
}

int main() {
    int n = 3000;  // Increase matrix size to 1000x1000
    double *A = (double *)malloc(n * n * sizeof(double));
    double *B = (double *)malloc(n * n * sizeof(double));
    double *C = (double *)malloc(n * n * sizeof(double));

    if (A == NULL || B == NULL || C == NULL) {
        fprintf(stderr, "Memory allocation failed!\n");
        return 1;
    }

    // Initialize matrices A and B with some values
    for (int i = 0; i < n * n; i++) {
        A[i] = (double)(rand() % 10);  // Random values 0-9
        B[i] = (double)(rand() % 10);  // Random values 0-9
    }

    // Start timing
    clock_t start = clock();

    // Perform matrix multiplication using cblas_dgemm (Row-major order)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                n, n, n, 1.0, A, n, B, n, 0.0, C, n);

    // Stop timing
    clock_t end = clock();
    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;

    // Output the result (or just the first element to verify correctness)
    printf("Result (C[0]): %f\n", C[0]);
    printf("Matrix multiplication time: %f seconds\n", time_spent);

    // Print memory usage
    print_mem_usage();

    // --- Conditional Printf for BLAS Version ---
    #ifdef USE_OPENBLAS
      // This code block is only compiled if -DUSE_OPENBLAS is set
      printf("BLAS library: OpenBLAS (%s)\n", openblas_get_config());
    #else
      // This is the fallback. It will be used for ATLAS or any other BLAS
      printf("BLAS library: ATLAS (or other non-OpenBLAS library)\n");
    #endif
    // --- End Conditional Printf ---

    // --- Conditional Printf for Compiler ---
    // Use compile-time macros to check which compiler is being used
    printf("Compiler used: ");
    #if defined(__clang__)
        printf("Clang %s\n", __clang_version__);
    #elif defined(__GNUC__)
        printf("GCC %d.%d.%d\n", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__);
    #else
        printf("Unknown Compiler\n");
    #endif
    // --- End Conditional Printf ---

    // Free memory
    free(A);
    free(B);
    free(C);

    return 0;
}