# SELinux Security Lab Report

## 1. Environment Setup

### 1.1 Prerequisites Installation
```bash
# Install required tools
sudo apt install vagrant ansible
vagrant plugin install vagrant-vmware-desktop
```

### 1.2 Lab Environment Initialization
```bash
# Clone and setup the environment
git clone <repository-url>
cd selinux/src
vagrant up
```

{vagrant_up_output}

## 2. SELinux Configuration Verification

### 2.1 Initial State
```bash
# SSH into the VM
vagrant ssh

# Verify SELinux status
sestatus
```

{selinux_status}

**Explanation:**
- `enforcing` mode means SELinux is actively enforcing security policies
- `targeted` policy focuses on protecting network daemons
- The context labels show the security context of processes and files

### 2.2 Understanding SELinux Contexts
```bash
# View process contexts
ps auxZ | grep nginx
```

{process_contexts}

**Context Components:**
1. **User**: Identifies the SELinux user (system_u)
2. **Role**: Defines the role (system_r)
3. **Type**: Most important part, defines the domain (httpd_t)
4. **Level**: MLS/MCS security level (s0)

## 3. Attack Simulation

### 3.1 Web Application Exploitation
```bash
# Basic command injection
curl "http://localhost:8080/?cmd=id"
```

{web_exploit_output}

```bash
# Attempt to read sensitive file
curl "http://localhost:8080/?cmd=cat+/etc/shadow"
```

{selinux_denial}

**SELinux Prevention:**
- Process running as `httpd_t` domain
- Prevented from accessing files with `shadow_t` context
- AVC denial logged in audit log

### 3.2 Privilege Escalation Attempt
```bash
# Locate SUID binary
curl "http://localhost:8080/?cmd=find+/+-perm+-4000+2>/dev/null"

# Attempt exploitation
curl "http://localhost:8080/?cmd=/usr/local/bin/suid_demo"
```

{privesc_attempt}

## 4. Security Monitoring

### 4.1 Real-time Audit Log Analysis
```bash
# View SELinux denials
sudo tail -f /var/log/audit/audit.log | grep AVC
```

{audit_log_output}

**Understanding AVC Messages:**
```
type=AVC msg=audit(timestamp): avc: denied { action } for pid=XX 
comm="process_name" path="/path/to/file"
```
- `type=AVC`: Indicates SELinux denial
- `action`: Attempted operation (read, write, execute)
- `comm`: Process name
- `path`: Target resource

### 4.2 Security Report Generation
```bash
# Generate comprehensive report
cd /home/vagrant
./generate_report.sh
```

{security_report}

### 4.3 Alert Analysis
```bash
# View detailed SELinux alerts
sudo sealert -a /var/log/audit/audit.log
```

{selinux_alerts}

## 5. SELinux Policy Analysis

### 5.1 Boolean Settings
```bash
# View all boolean settings
getsebool -a | grep httpd
```

{boolean_settings}

**Key Booleans:**
- `httpd_execmem`: Controls if web server can execute memory
- `httpd_read_user_content`: Controls access to user home directories

### 5.2 Policy Violations Analysis
```bash
# Analyze denials
sudo audit2why < /var/log/audit/audit.log
```

{policy_analysis}

### 5.3 Custom Container Policy
```bash
# View generated container policy
cat /tmp/custom_container.cil
```

{container_policy}

## 6. Security Improvements

### 6.1 SELinux File Contexts
```bash
# List current file contexts
ls -Z /var/www/vuln_app/
```

{file_contexts}

### 6.2 Process Domain Transitions
```bash
# View process transitions
ps -eZ | grep nginx
ps -eZ | grep php-fpm
```

{process_transitions}

## 7. Lab Cleanup
```bash
# Destroy lab environment
vagrant destroy -f
```

## 8. Key Findings

1. **Access Control Effectiveness**
   - SELinux successfully prevented unauthorized file access
   - Process isolation maintained through domain separation
   - Audit logs provided detailed security events

2. **Policy Enforcement**
   - Type enforcement prevented privilege escalation
   - Container isolation maintained
   - File context labels properly enforced

3. **Monitoring Capabilities**
   - Real-time alert detection
   - Comprehensive audit logging
   - Detailed violation reports

## 9. Conclusion

This lab demonstrated SELinux's effectiveness in:
- Preventing unauthorized access
- Containing compromised services
- Providing detailed security monitoring
- Enforcing principle of least privilege

SELinux proved to be a robust security mechanism for enforcing mandatory access control and containing potential security breaches.
