#!/bin/bash
echo "=== Privilege Escalation Attempts ==="
ausearch -k privilege_escalation | tail -n 20

echo -e "\n=== SUID Binary Modifications ==="
ausearch -k suid_modification | tail -n 20

echo -e "\n=== Recent SELinux Denials ==="
sealert -a /var/log/audit/audit.log | grep -A 5 'AVC denial'