#!/usr/bin/env python3
"""Generate a lightweight SEO/indexing health report for PatiParent."""
from __future__ import annotations

from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen
import json
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs' / 'seo_index_health_report.md'
CANONICAL_HOST = 'https://www.patiparent.com'
URLS = [
    '/',
    '/pati-gezdirme',
    '/pati-bnb',
    '/pati-match',
    '/pati-family',
    '/pati-dostu-oteller',
    '/veterinerler',
    '/pet-kuaforleri',
    '/robots.txt',
    '/sitemap.xml',
]

class MetaParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.title = ''
        self._in_title = False
        self.description = ''
        self.canonical = ''
        self.robots = ''

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'title':
            self._in_title = True
        if tag == 'meta' and attrs.get('name') == 'description':
            self.description = attrs.get('content', '')
        if tag == 'meta' and attrs.get('name') == 'robots':
            self.robots = attrs.get('content', '')
        if tag == 'link' and attrs.get('rel') == 'canonical':
            self.canonical = attrs.get('href', '')

    def handle_endtag(self, tag):
        if tag == 'title':
            self._in_title = False

    def handle_data(self, data):
        if self._in_title:
            self.title += data.strip()


def fetch(url: str) -> dict:
    req = Request(url, headers={
        'User-Agent': 'PatiParentSEOAudit/1.0 (+https://www.patiparent.com)',
        'Cache-Control': 'no-cache',
    })
    try:
        with urlopen(req, timeout=20) as response:
            content_type = response.headers.get('content-type', '')
            body = response.read().decode('utf-8', errors='replace')
            return {
                'url': url,
                'status': response.status,
                'final_url': response.geturl(),
                'content_type': content_type,
                'body': body,
                'error': '',
            }
    except HTTPError as exc:
        return {'url': url, 'status': exc.code, 'final_url': url, 'content_type': '', 'body': '', 'error': str(exc)}
    except URLError as exc:
        return {'url': url, 'status': 0, 'final_url': url, 'content_type': '', 'body': '', 'error': str(exc)}


def status_icon(ok: bool) -> str:
    return 'PASS' if ok else 'CHECK'


def build_report() -> str:
    now = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')
    rows = []
    issues = []
    sitemap_urls = []

    for path in URLS:
        url = CANONICAL_HOST + path
        result = fetch(url)
        body = result['body']
        parser = MetaParser()
        if 'text/html' in result['content_type']:
            parser.feed(body)
        if path == '/sitemap.xml':
            sitemap_urls = re.findall(r'<loc>(.*?)</loc>', body)
        ok_status = result['status'] == 200
        if not ok_status:
            issues.append(f'{url} status {result["status"]}: {result["error"]}')
        if path not in ['/robots.txt', '/sitemap.xml']:
            if 'A new Flutter project' in body or 'patimatch_app' in body:
                issues.append(f'{url} still contains default Flutter SEO text.')
            if parser.canonical and not parser.canonical.startswith(CANONICAL_HOST):
                issues.append(f'{url} canonical mismatch: {parser.canonical}')
        rows.append({
            'path': path,
            'status': result['status'],
            'final_url': result['final_url'],
            'content_type': result['content_type'],
            'title': parser.title,
            'description': parser.description,
            'canonical': parser.canonical,
        })

    required_sitemap = [CANONICAL_HOST + p for p in URLS if p not in ['/robots.txt', '/sitemap.xml']]
    missing_sitemap = [u for u in required_sitemap if u not in sitemap_urls]
    if missing_sitemap:
        issues.append('Sitemap missing URLs: ' + ', '.join(missing_sitemap))

    md = [
        '# PatiParent SEO / Index Health Report',
        '',
        f'Generated: {now}',
        '',
        '## Summary',
        '',
        f'- Canonical host: `{CANONICAL_HOST}`',
        f'- Checked URLs: `{len(URLS)}`',
        f'- Sitemap URLs found: `{len(sitemap_urls)}`',
        f'- Current status: `{status_icon(not issues)}`',
        '',
        '## Findings',
        '',
    ]
    if issues:
        md.extend(f'- CHECK: {issue}' for issue in issues)
    else:
        md.append('- PASS: Live pages, robots and sitemap are reachable and aligned to the canonical host.')
    md.extend([
        '',
        '## URL Checks',
        '',
        '| Path | HTTP | Title | Canonical |',
        '|---|---:|---|---|',
    ])
    for row in rows:
        title = row['title'].replace('|', '/') if row['title'] else row['content_type']
        canonical = row['canonical'] or row['final_url']
        md.append(f"| `{row['path']}` | {row['status']} | {title} | {canonical} |")
    md.extend([
        '',
        '## Search Engine Action Checklist',
        '',
        '1. Google Search Console: verify `https://www.patiparent.com/` URL-prefix property or domain property.',
        '2. Submit sitemap: `https://www.patiparent.com/sitemap.xml`.',
        '3. URL Inspection > Request indexing for `/`, `/pati-gezdirme`, `/pati-bnb`, `/pati-match`, `/pati-family`.',
        '4. Bing Webmaster Tools: add/import the same site and submit the same sitemap.',
        '5. Recheck `site:patiparent.com` after Google recrawls. This can take hours to days.',
        '',
        '## Notes',
        '',
        '- Google and Bing are separate indexes; Edge/Bing showing no result does not mean Google is broken.',
        '- If Google still shows `A new Flutter project`, it is using an old cached snippet. Request indexing is the fastest correction path.',
        '- Keep canonical, robots and sitemap on the same `www.patiparent.com` host to reduce duplicate-domain confusion.',
        '',
        '## Raw Snapshot',
        '',
        '```json',
        json.dumps(rows, ensure_ascii=False, indent=2),
        '```',
    ])
    return '\n'.join(md) + '\n'

if __name__ == '__main__':
    OUT.write_text(build_report(), encoding='utf-8')
    print(f'Wrote {OUT}')
