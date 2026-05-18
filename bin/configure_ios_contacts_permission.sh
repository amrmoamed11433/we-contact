#!/usr/bin/env bash
set -euo pipefail

# Adds the iOS contacts permission description required by flutter_contacts.
# Safe to run multiple times.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFO_PLIST="${1:-$ROOT/ios/Runner/Info.plist}"
MESSAGE="WE Packages Manager needs contacts access to choose a customer and fill the name and phone number automatically."

if [[ ! -f "$INFO_PLIST" ]]; then
  exit 0
fi

if [[ "$(uname -s)" == "Darwin" && -x /usr/libexec/PlistBuddy ]]; then
  /usr/libexec/PlistBuddy -c "Set :NSContactsUsageDescription $MESSAGE" "$INFO_PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :NSContactsUsageDescription string $MESSAGE" "$INFO_PLIST"
else
  python3 - "$INFO_PLIST" "$MESSAGE" <<'PY'
import plistlib
import sys
from pathlib import Path
path = Path(sys.argv[1])
message = sys.argv[2]
data = plistlib.loads(path.read_bytes())
data['NSContactsUsageDescription'] = message
path.write_bytes(plistlib.dumps(data))
PY
fi
