import urllib.request
import re
import json

req = urllib.request.Request('https://www.kaggle.com/datasets/gpiosenka/butterfly-images40-species', headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        html = response.read().decode('utf-8')
        # Extract script tag containing the state
        matches = re.findall(r'<script class="kaggle-component" nonce=".*?" type="application/json">(.*?)</script>', html)
        if matches:
            for match in matches:
                if 'dataset' in match:
                    print("Found dataset JSON")
                    break
        else:
            print("No kaggle-component scripts found.")
except Exception as e:
    print('Error:', e)
