#!/bin/bash

echo "=== Apache Configuration Check ==="
echo ""

# 1. Check syntax
echo "1. Configuration syntax:"
sudo apache2ctl configtest
echo ""

# 2. Check EnableSendfile setting
echo "2. EnableSendfile setting:"
grep -i "enablesendfile" /etc/apache2/apache2.conf
echo ""

# 3. Check active sites
echo "3. Active sites:"
sudo apache2ctl -S 2>/dev/null | grep -A2 "port 80"
echo ""

# 4. Check directory permissions
echo "4. /var/www/html permissions:"
ls -ld /var/www/html
ls -la /var/www/html/index.html 2>/dev/null || echo "No index.html found"
echo ""

# 5. Quick test
echo "5. Quick test:"
timeout 2 curl -s -o /dev/null -w "HTTP: %{http_code}\n" http://localhost/ || echo "Curl failed or timeout"
echo ""