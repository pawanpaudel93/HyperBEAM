#!/bin/bash

# Option 1: Run in foreground with logs (blocks terminal, use Ctrl+C to stop)
# sudo docker run --rm \
#   --name hyperbeam-node \
#   -p 10000:10000 \
#   -v /ar.io:/ar.io \
#   -v /ar.io/node/cu-node/hb/HyperBEAM/.wallets/wallet.json:/opt/wallet.json \
#   -e HB_KEY=/opt/wallet.json \
#   hyperbeam-custom

# Option 2: Run detached, then follow logs (recommended)
sudo docker run -d \
  --name hyperbeam-node \
  -p 10000:10000 \
  -v /ar.io:/ar.io \
  -v /ar.io/node/cu-node/hb/HyperBEAM/.wallets/wallet.json:/opt/wallet.json \
  -e HB_KEY=/opt/wallet.json \
  --restart unless-stopped \
  hyperbeam-custom foreground

# Follow logs after starting
echo "Container started."
echo ""
echo "To follow logs run:"
echo "sudo docker logs -f hyperbeam-node"