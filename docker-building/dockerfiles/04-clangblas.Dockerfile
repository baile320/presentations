FROM silkeh/clang:19

# Install OpenBLAS
RUN apt-get update && apt-get install -y build-essential libopenblas-dev

WORKDIR /work
COPY src/matmul.c .

# Compile with Clang and OpenBLAS !! NOTE THE STATIC LINKING !!
RUN clang matmul.c -o 04-clangblas -DUSE_OPENBLAS -lopenblas -static

CMD ["cp", "04-clangblas", "/output/"]
