FROM gcc:12

# Install ATLAS
RUN apt-get update && apt-get install -y build-essential libatlas-base-dev

WORKDIR /work
COPY src/matmul.c .

# Compile with GCC 12 and ATLAS !! NOTE THE STATIC LINKING !!
RUN gcc matmul.c -o 02-gcc12atlas -lcblas -latlas -static

CMD ["cp", "02-gcc12atlas", "/output/"]
