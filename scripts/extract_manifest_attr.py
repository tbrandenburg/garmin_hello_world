#!/usr/bin/env python3
"""Extract a Connect IQ manifest attribute."""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        return 1

    manifest_path = Path(sys.argv[1])
    attribute = sys.argv[2]

    if not manifest_path.exists():
        return 0

    try:
        tree = ET.parse(manifest_path)
        ns = {"iq": "http://www.garmin.com/xml/connectiq"}
        app = tree.getroot().find("iq:application", ns)
        if app is None:
            return 0
        value = app.get(attribute, "") or ""
        sys.stdout.write(value)
    except Exception:
        return 0

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
