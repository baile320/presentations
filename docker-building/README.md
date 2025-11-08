# Introduction
This folder contains a demo to show how docker can be used to (statically) link different C libraries, compilers, or compiler versions. This effectively creates version controlled build environments for your source code that do not depend on the host's installed libraries or other sorts of software management systems (e.g. linux environment modules)

# Prerequisites
1. A host where you are able to run docker.

# How to Run
1. Run `build.sh`, which will build images from the Dockerfiles under `dockerfiles/`, and then run them to compile the code from `src/matmul.c`.
2. If `build.sh` runs successfully, the executable, compiled code, will be available under `outputs/`
3. Running the code from `outputs/` will give you details about the calculation time, memory use, libraries, and compilers used when the code was compiled.

# Scratch notes
Rsync this directory somewhere useful, overwriting is eisting
```
rsync -avz --delete ./docker-building/ adm-baile320@cse-docker-sandbox-01.cse.umn.edu:/export/scratch/docker-building/
```

Gotchas (used chatgpt to help troubleshoot)
- DNS (use host network)
- docker hub issues (use proxy.oit.umn.edu)
- work through some C/linking errors