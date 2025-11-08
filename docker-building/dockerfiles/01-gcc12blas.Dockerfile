FROM gcc:12

# Install OpenBLAS
RUN apt-get update && apt-get install -y build-essential libopenblas-dev

WORKDIR /work
COPY src/matmul.c .

# Compile with GCC 12 and OpenBLAS !! NOTE THE STATIC LINKING !!
RUN gcc matmul.c -o 01-gcc12blas -DUSE_OPENBLAS -lopenblas -static

CMD ["cp", "01-gcc12blas", "/output/"]
