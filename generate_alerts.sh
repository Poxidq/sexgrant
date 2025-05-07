#!/bin/bash

# Add timestamps and colored output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== SELinux Security Lab Demonstration ===${NC}"

# 1. Show initial SELinux status
echo -e "\n${GREEN}1. Current SELinux Status:${NC}"
sestatus
ps -eZ | grep -E "nginx|httpd|sshd"

# 2. Test SSH brute force protection
echo -e "\n${GREEN}2. Testing SSH Brute Force Protection:${NC}"
for i in {1..10}; do
  echo "Attempt $i..."
  sshpass -p "wrongpass" ssh -o StrictHostKeyChecking=no testuser@localhost
done

# 3. Test file access controls
echo -e "\n${GREEN}3. Testing File Access Controls:${NC}"
curl "http://localhost:8080/?cmd=cat+/etc/shadow"
curl "http://localhost:8080/?cmd=echo+\"hack\"+>/etc/passwd"
curl "http://localhost:8080/?cmd=chmod+777+/etc/ssh/sshd_config"

# 4. Test process transitions
echo -e "\n${GREEN}4. Testing Process Transitions:${NC}"
curl "http://localhost:8080/?cmd=/usr/bin/sudo+su+-"
curl "http://localhost:8080/?cmd=newrole+-r+system_r"

# 5. Test network controls
echo -e "\n${GREEN}5. Testing Network Controls:${NC}"
curl "http://localhost:8080/?cmd=nc+-l+80"
curl "http://localhost:8080/?cmd=python3+-m+http.server+443"

# 6. Monitor and report
echo -e "\n${GREEN}6. Generating Security Report:${NC}"
sudo /usr/local/bin/security_dashboard

# 7. Show real-time monitoring
echo -e "\n${GREEN}7. Real-time Security Monitoring:${NC}"
echo "Press Ctrl+C to stop monitoring..."
sudo tail -f /var/log/audit/audit.log | grep --color=auto "AVC"