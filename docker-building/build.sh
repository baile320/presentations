#!/usr/bin/env bash
set -euo pipefail

# This ensures the output files are owned by you, not root.
REAL_UID=$(id -u ${SUDO_USER:-$USER})
REAL_GID=$(id -g ${SUDO_USER:-$USER})
echo "✅ Running as UID: $REAL_UID, GID: $REAL_GID. Output files will be owned by this user."

# Make sure output directory exists
mkdir -p output

# Ensure the output dir is owned by the user, even if `sudo` created it as root.
chown "${REAL_UID}:${REAL_GID}" output

# Map build names to Dockerfiles
declare -A builds=(
  [gcc12blas]="dockerfiles/01-gcc12blas.Dockerfile"
  [gcc12atlas]="dockerfiles/02-gcc12atlas.Dockerfile"
  [gcc15blas]="dockerfiles/03-gcc15blas.Dockerfile"
  [clangblas]="dockerfiles/04-clangblas.Dockerfile"
  [clangatlas]="dockerfiles/05-clangatlas.Dockerfile"
)

# Loop over builds
for name in "${!builds[@]}"; do
  echo "====================================================="
  echo "Building image: $name"
  echo "Using Dockerfile: ${builds[$name]}"
  echo "====================================================="

  # Build the image
  docker build \
    --network="host" \
    -f "${builds[$name]}" -t demo:$name .

  # Run it and copy output binary to host ./output/
  docker run --rm --user "${REAL_UID}:${REAL_GID}" -v "$(pwd)/output:/output" demo:$name
done

echo
echo "====================================================="
echo "✅ Build complete. Binaries copied to ./output/:"
ls -lh output/
echo "====================================================="
