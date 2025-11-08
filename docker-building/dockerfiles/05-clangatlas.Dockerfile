FROM silkeh/clang:19

# Install ATLAS
RUN apt-get update && apt-get install -y build-essential libatlas-base-dev

WORKDIR /work
COPY src/matmul.c .

# Compile with Clang and ATLAS !! NOTE THE STATIC LINKING !!
RUN clang matmul.c -o 05-clangatlas -lcblas -latlas -static

CMD ["cp", "05-clangatlas", "/output/"]
