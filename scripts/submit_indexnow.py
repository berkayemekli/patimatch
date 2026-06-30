#!/usr/bin/env python3
"""Submit PatiParent canonical URLs to IndexNow-supported search engines."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
KEY_FILE = ROOT / 'app' / 'web' / 'indexnow.txt'
SITEMAP = ROOT / 'app' / 'web' / 'sitemap.xml'
ENDPOINT = 'https://api.indexnow.org/indexnow'
HOST = 'www.patiparent.com'
KEY_LOCATION = 'https://www.patiparent.com/indexnow.txt'


def urls_from_sitemap() -> list[str]:
    ns = {'sm': 'http://www.sitemaps.org/schemas/sitemap/0.9'}
    tree = ET.parse(SITEMAP)
    return [node.text.strip() for node in tree.findall('.//sm:loc', ns) if node.text]


def submit(dry_run: bool = False) -> int:
    key = KEY_FILE.read_text(encoding='ascii').strip()
    urls = urls_from_sitemap()
    payload = {
        'host': HOST,
        'key': key,
        'keyLocation': KEY_LOCATION,
        'urlList': urls,
    }
    print(json.dumps(payload, indent=2, ensure_ascii=False))
    if dry_run:
        print('DRY RUN: not submitted')
        return 0
    data = json.dumps(payload).encode('utf-8')
    req = Request(ENDPOINT, data=data, headers={'Content-Type': 'application/json'}, method='POST')
    try:
        with urlopen(req, timeout=30) as response:
            print(f'IndexNow response: {response.status} {response.reason}')
            return 0 if response.status in (200, 202) else 1
    except HTTPError as exc:
        print(f'IndexNow HTTP error: {exc.code} {exc.reason}', file=sys.stderr)
        print(exc.read().decode('utf-8', errors='replace'), file=sys.stderr)
        return 1
    except URLError as exc:
        print(f'IndexNow URL error: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(submit('--dry-run' in sys.argv))
