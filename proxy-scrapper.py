"""
Proxy Scraper for JDownloader2
"""
from __future__ import annotations
import json
import requests
from bs4 import BeautifulSoup

# Constants
PROXY_SOURCE_URL = "https://socks-proxy.net/#list"
OUTPUT_FILE = 'proxylist.jdproxies'
USER_AGENT_HEADER = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/120.0.0.0 Safari/537.36"
)

# JDownloader2 proxy structure
def create_proxy_record(
        # address: Optional[str],
        address: str | None,
        port: int,
        proxy_type: str,
        enabled: bool = True,
) -> dict[str, object]:
    """Create a single proxy entry in JDownloader2-compatible format."""
    proxy_record = dict()
    proxy_preferences = dict()
    proxy_preferences["username"] = None
    proxy_preferences["password"] = None
    proxy_preferences["address"] = address
    proxy_preferences["port"] = port
    proxy_preferences["type"] = proxy_type
    proxy_preferences['preferNativeImplementation'] = False
    proxy_preferences['resolveHostName'] = False
    proxy_preferences['connectMethodPreferred'] = False
    proxy_record['proxy'] = proxy_preferences
    proxy_record['rangeRequestsSupported'] = True
    proxy_record['filter'] = None
    proxy_record['pac'] = False
    proxy_record['reconnectSupported'] = False
    proxy_record['enabled'] = enabled
    # json_data = proxy_record
    return proxy_record

# Scraping logic
def fetch_proxy_page() -> str:
    """Fetch the HTML content of the proxy list page."""
    #proxy_site_url = 'https://socks-proxy.net/#list'
    response = requests.get(PROXY_SOURCE_URL, headers={'User-Agent': USER_AGENT_HEADER}, timeout=15)
    response.raise_for_status()
    return response.text

def parse_proxies(html: str):
    """Parse proxy entries from the HTML table."""
    #soup = BeautifulSoup(res.text, "lxml")
    soup = BeautifulSoup(html, "html.parser")

    proxy_list = list()
    rows = soup.select("tbody tr")
    for row in rows:
        proxy_definition = []
        for td in row.select("td")[:8]:
            proxy_definition.append(td.text)

        try:
            port = int(proxy_definition[1])
        except ValueError:
            continue

        proxy_list.append(
            create_proxy_record(
                address=proxy_definition[0],
                port=port,
                proxy_type=proxy_definition[4].upper(),
                enabled=True,
            )
        )
    return proxy_list

def main():
    """Main execution function."""
    # Default "no proxy" entry required by JDownloader
    proxy_list = list([
        create_proxy_record(
            address=None,
            port=80,
            proxy_type="NONE",
            enabled=True,
        )
    ])

    html = fetch_proxy_page()
    proxy_list.extend(parse_proxies(html))

    json_output = {"customProxyList": proxy_list}

    with open(OUTPUT_FILE, 'w', encoding="utf-8") as file:
        json.dump(json_output, file, indent=2)

    print(f"Generated {len(proxy_list)} proxies -> {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
