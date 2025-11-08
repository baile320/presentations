FROM gcc:15

# Install OpenBLAS
RUN apt-get update && apt-get install -y build-essential libopenblas-dev

WORKDIR /work
COPY src/matmul.c .

# Compile with GCC 15 and OpenBLAS !! NOTE THE STATIC LINKING !!
RUN gcc matmul.c -o 03-gcc15blas -DUSE_OPENBLAS -lopenblas -static

CMD ["cp", "03-gcc15blas", "/output/"]
