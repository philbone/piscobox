#!/bin/bash

# Test Apache configuration after setup

echo "=== Apache Diagnostic Test ==="
echo ""

# 1. Check Apache status
echo "1. Apache Service Status:"
systemctl status apache2 --no-pager --lines=3
echo ""

# 2. Check if synced folder is mounted
echo "2. Synced Folder Mount:"
mount | grep -i "www\|html" || echo "Not found in mount"
echo ""

# 3. Check directory permissions
echo "3. Directory Permissions:"
ls -ld /var/www/html
echo "Contents (first 5):"
ls -la /var/www/html/ 2>/dev/null | head -10
echo ""

# 4. Check Apache configuration
echo "4. Apache Configuration Test:"
apache2ctl configtest
echo ""

# 5. Check active VirtualHost
echo "5. Active VirtualHost:"
apache2ctl -S 2>/dev/null | grep -A5 "port 80"
echo ""

# 6. Test web server locally
echo "6. Local Web Test:"
curl -I http://localhost/ 2>/dev/null | head -1
echo ""

# 7. Check error log
echo "7. Recent Error Log:"
tail -10 /var/log/apache2/error.log 2>/dev/null || echo "No error log"
echo ""

# 8. Check AppArmor/SELinux
echo "8. Security Modules:"
aa-status 2>/dev/null | grep -i "apache" || echo "AppArmor not blocking Apache"
echo ""