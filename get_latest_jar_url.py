#!/bin/python

import urllib.request
import json
with urllib.request.urlopen("https://launchermeta.mojang.com/mc/game/version_manifest.json") as manifest_request:
    manifest = json.loads(manifest_request.read().decode("utf-8"))
    target_url = [v for v in manifest["versions"] if v["id"] == manifest["latest"]["release"]][0]["url"]
    with urllib.request.urlopen(target_url) as target_request:
        print(json.loads(target_request.read().decode("utf-8"))["downloads"]["server"]["url"])
