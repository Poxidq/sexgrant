# SquirrelMail SELinux Testing Guide

## 1. Basic Functionality Testing

```bash
# Test web access
curl -I http://localhost/squirrelmail

# Test IMAP connection
telnet localhost 143

# Check service status
systemctl status httpd
systemctl status postfix
```

## 2. SELinux Context Verification

```bash
# Check SquirrelMail file contexts
ls -Z /usr/share/squirrelmail
ls -Z /etc/squirrelmail

# Verify Apache context
ps -eZ | grep httpd

# Check port contexts
semanage port -l | grep -E '80|143|25'
```

## 3. SELinux Policy Testing

### Test Policy Rules
```bash
# Generate test policy
cat > test_squirrelmail.te << EOF
module test_squirrelmail 1.0;

require {
    type httpd_t;
    type httpd_sys_content_t;
    class file { read write };
}

# Test rule
allow httpd_t httpd_sys_content_t:file { read write };
EOF

# Compile and load policy
make -f /usr/share/selinux/devel/Makefile test_squirrelmail.pp
semodule -i test_squirrelmail.pp

# Verify policy
semodule -l | grep test_squirrelmail
```

### Test Denials
```bash
# Monitor denials in real-time
ausearch -m AVC -ts recent | audit2allow

# Generate detailed report
sealert -a /var/log/audit/audit.log

# Test specific access
curl -v http://localhost/squirrelmail/config.php
```

## 4. Security Testing

### Port Access Testing
```bash
# Test IMAP port
nc -zv localhost 143

# Test SMTP port
nc -zv localhost 25

# Check port contexts
semanage port -l | grep -E '143|25'
```

### File Access Testing
```bash
# Test configuration access
curl -v http://localhost/squirrelmail/config.php

# Test attachment directory
ls -Z /var/lib/squirrelmail/attachments/
```

## 5. Policy Modification

### Create Custom Policy
```bash
# Create policy file
cat > squirrelmail_custom.te << EOF
module squirrelmail_custom 1.0;

require {
    type httpd_t;
    type httpd_sys_content_t;
    type port_t;
    class tcp_socket { name_connect };
    class file { read write };
}

# Allow IMAP connection
allow httpd_t port_t:tcp_socket name_connect;

# Allow configuration access
allow httpd_t httpd_sys_content_t:file { read write };
EOF

# Compile and load
make -f /usr/share/selinux/devel/Makefile squirrelmail_custom.pp
semodule -i squirrelmail_custom.pp
```

### Test Policy Changes
```bash
# Monitor for new denials
ausearch -m AVC -ts recent | audit2allow

# Test IMAP connection
telnet localhost 143

# Check policy effectiveness
sealert -a /var/log/audit/audit.log
```

## 6. Troubleshooting

### Common Issues
```bash
# Check SELinux status
getenforce
sestatus

# View detailed denials
sealert -a /var/log/audit/audit.log

# Check service contexts
ps -eZ | grep -E 'httpd|postfix'

# Verify file contexts
restorecon -Rv /usr/share/squirrelmail
```

### Fix Context Issues
```bash
# Fix file contexts
restorecon -Rv /usr/share/squirrelmail
restorecon -Rv /etc/squirrelmail

# Add custom context
semanage fcontext -a -t httpd_sys_content_t "/usr/share/squirrelmail(/.*)?"
restorecon -Rv /usr/share/squirrelmail
```

## 7. Performance Testing

```bash
# Monitor SELinux performance impact
time curl http://localhost/squirrelmail

# Check audit log size
ls -lh /var/log/audit/audit.log

# Monitor system calls
strace -f -p $(pgrep httpd)
```

## 8. Security Hardening

### Additional Policy Rules
```bash
# Create hardening policy
cat > squirrelmail_hardening.te << EOF
module squirrelmail_hardening 1.0;

require {
    type httpd_t;
    type httpd_sys_content_t;
    class file { read write };
}

# Prevent unauthorized access
dontaudit httpd_t httpd_sys_content_t:file write;
EOF

# Apply hardening
make -f /usr/share/selinux/devel/Makefile squirrelmail_hardening.pp
semodule -i squirrelmail_hardening.pp
```

### Verify Hardening
```bash
# Test access restrictions
curl -v http://localhost/squirrelmail/config.php

# Check for denials
ausearch -m AVC -ts recent | audit2allow
```

## 9. Cleanup

```bash
# Remove test policies
semodule -r test_squirrelmail
semodule -r squirrelmail_custom
semodule -r squirrelmail_hardening

# Restore original contexts
restorecon -Rv /usr/share/squirrelmail
restorecon -Rv /etc/squirrelmail
```

## 10. Documentation

```bash
# Generate policy documentation
sepolicy manpage -p /usr/share/man/man8
sepolicy html -p /usr/share/doc/selinux

# Create custom documentation
cat > /usr/local/share/squirrelmail/SELINUX.md << EOF
# SquirrelMail SELinux Configuration

## Policy Details
- IMAP access: port 143
- SMTP access: port 25
- Web access: port 80

## Context Rules
- Web content: httpd_sys_content_t
- Configuration: httpd_sys_rw_content_t

## Troubleshooting
See /var/log/audit/audit.log for detailed information
EOF
``` 