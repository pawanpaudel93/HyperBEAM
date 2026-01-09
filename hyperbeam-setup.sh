#!/bin/bash

# Ensure directories exist on the mounted volume
mkdir -p /ar.io/hyperbeam-data /ar.io/tmp

# Create symlink from /root/tmp to our volume (for key file storage)
if [ ! -L /root/tmp ] && [ ! -d /root/tmp ]; then
  ln -sf /ar.io/tmp /root/tmp
elif [ -d /root/tmp ] && [ ! -L /root/tmp ]; then
  # If /root/tmp is a regular directory, backup and replace with symlink
  mv /root/tmp /root/tmp.bak 2>/dev/null || true
  ln -sf /ar.io/tmp /root/tmp
fi

# Start HyperBEAM
#exec /opt/_build/genesis_wasm/rel/hb/bin/hb "$@"