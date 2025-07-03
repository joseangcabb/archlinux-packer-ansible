#!/bin/bash

set -euo pipefail

USERNAME="$1"
PASSWORD="$2"

useradd -m -s /bin/bash -G wheel "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-$USERNAME
chmod 440 /etc/sudoers.d/90-$USERNAME
