# JDownloader proxy list generator

Using **socks-proxy.net**, this script builds a list of public proxies that can be imported and used directly in **JDownloader**.

## Requirements
- **Python 3**
- **Windows OS** (batch script)

## Setup Process
1. Download the project **or** use this [direct link](https://github.com/diogoguerreiro3/jdproxygenerator/archive/refs/heads/main.zip).
2. Extract the contents.
3. Run the batch script (`proxy.bat`) by double-clicking it, **or** from a terminal (CMD / PowerShell):
    ```console
    cd C:\YOUR-PATH\jdproxygenerator-main
    .\proxy.bat
    ```
    **Note:** The batch script automatically creates a Python virtual environment, installs dependencies (`pip install -r requirements.txt`), and runs the proxy generator (`python proxy-scrapper.py`).
4. A JSON file named `proxylist.jdproxies` will be created in the same directory.</br>
    - This file can be imported into **JDownloader -> Settings -> Connection Manager**.
5. Start downloading! 🙃</br>
    **Note:** As the list is dynamic, when you have burned all your proxies just replace the list with a newly generated one. 
---
## Credits
This project is a fork of masterofobzene’s JDproxygenerator:
https://github.com/masterofobzene/JDproxygenerator
