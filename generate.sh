#!/bin/bash
# Generates the sukramj.dev site: start page, go-import pages, 404.
# Usage: ./generate.sh .   (edit MODS / the project lists, run, commit)
set -euo pipefail
cd "$1"
# Go libraries served as sukramj.dev/<repo> (go-import → github.com/SukramJ/<repo>).
MODS=(go-mqtt go-modbus go-hamapping go-hamqtt go-ha-catalog go-openccu-data godevccu)
tag() { echo "<meta name=\"go-import\" content=\"sukramj.dev/$1 git https://github.com/SukramJ/$1\">"; }
head_() { cat <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$1</title>
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
$2
<style>
:root{color-scheme:light dark;--fg:#1b1f24;--bg:#fff;--mut:#57606a;--a:#0969da}
@media (prefers-color-scheme:dark){:root{--fg:#e6edf3;--bg:#0d1117;--mut:#8d96a0;--a:#4493f8}}
body{margin:0 auto;max-width:44rem;padding:3rem 1rem;font:16px/1.6 system-ui,sans-serif;color:var(--fg);background:var(--bg)}
a{color:var(--a)}h1{display:flex;align-items:center;gap:.6rem}h1 img{width:2.4rem;height:2.4rem}h2{margin-top:2rem}code{font:0.95em ui-monospace,monospace}p.m,li span{color:var(--mut)}
</style>
</head>
<body>
HTML
}
# item <repo> <description>
item() { echo "<li><a href=\"https://github.com/SukramJ/$1\"><code>$1</code></a> <span>— $2</span></li>"; }
{ head_ "sukramj.dev" ""
  echo '<h1><img src="/favicon.svg" alt="">sukramj.dev</h1>'
  echo '<p>Open-source projects around Homematic, MQTT and Home Assistant.</p>'
  echo '<h2>Homematic</h2><ul>'
  item aiohomematic "async Python library for Homematic(IP) via OpenCCU, CCU3, CUxD and CCU-Jack"
  item homematicip_local "Home Assistant integration for Homematic(IP)"
  item openccu-loom "Go daemon bridging Homematic to MQTT, REST, MCP and Matter"
  item godevccu "virtual CCU for testing"
  echo '</ul><h2>MQTT bridges</h2><ul>'
  item go-daikin2mqtt "Daikin ONECTA"
  item go-homeconnect2mqtt "Home Connect, local"
  item go-keba2mqtt "KEBA KeContact P40"
  item go-mtec2mqtt "M-TEC Energybutler"
  item go-unifi2mqtt "UniFi Network"
  item go-zendure2mqtt "Zendure"
  item go-raumfeld-connect "Teufel Raumfeld"
  echo '</ul><h2>Go libraries</h2><ul>'
  for m in "${MODS[@]}"; do echo "<li><a href=\"https://github.com/SukramJ/$m\"><code>sukramj.dev/$m</code></a></li>"; done
  echo '</ul><h2>Matter</h2>'
  echo '<p>Matter in pure Go lives at <a href="https://thingfabric.dev/">thingfabric.dev</a>.</p>'
  echo '<p class="m"><a href="https://github.com/SukramJ">github.com/SukramJ</a></p>'
  echo '</body>'; echo '</html>'; } > index.html
for m in "${MODS[@]}"; do
  mkdir -p "$m"
  { head_ "sukramj.dev/$m" "$(tag "$m")"
    echo "<p><code>go get sukramj.dev/$m</code></p>"
    echo "<p class=\"m\">Source: <a href=\"https://github.com/SukramJ/$m\">github.com/SukramJ/$m</a> · Reference: <a href=\"https://pkg.go.dev/sukramj.dev/$m\">pkg.go.dev</a></p>"
    echo '</body>'; echo '</html>'; } > "$m/index.html"
done
# 404 carries every tag so sub-package paths resolve (cmd/go parses the tags before the status code).
{ head_ "Not found · sukramj.dev" "$(for m in "${MODS[@]}"; do tag "$m"; done)"
  echo '<h1>Not found</h1><p>This page does not exist. <a href="/">sukramj.dev</a></p>'
  echo '</body>'; echo '</html>'; } > 404.html
echo sukramj.dev > CNAME
