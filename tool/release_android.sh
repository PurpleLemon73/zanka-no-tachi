#!/usr/bin/env bash
set -euo pipefail

# The shared candidate builder owns all gates so debug and production builds
# cannot drift. Production mode additionally fails closed on Git cleanliness,
# private signing configuration, package/version identity and signer identity.
exec "$(dirname "$0")/build_release_candidate.sh" release
