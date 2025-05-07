# SELinux Security Lab

This lab demonstrates SELinux security mechanisms, vulnerability exploitation, and security monitoring capabilities in a controlled environment. Learn how SELinux protects systems by attempting privilege escalation and monitoring the security responses.

## Prerequisites

- [Vagrant](https://www.vagrantup.com/downloads) 2.3+
- [VMware Desktop/Workstation](https://www.vmware.com/products/workstation-pro.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 2.9+

## Quick Start

1. **Clone and setup**:
```bash
git clone <repository-url>
cd selinux
```

2. **Start the environment**:
```bash
cd vagrant
vagrant up
```

3. **Run and debug ansible**:
```bash
PYTHONUNBUFFERED=1 ansible-playbook   -i ansible/vagrant_inventory.py   --become   -v   --extra-vars "ansible_python_interpreter=/usr/bin/python3"   -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"   ansible/playbook.yml
```

## Accessing the Lab

### Get VM IP address
```bash
# Method 1: Using ssh-config
vagrant ssh-config | grep HostName

# Method 2: From within the VM
vagrant ssh -c "ip addr show eth0"
```

### SSH Access
```bash
# Direct SSH
vagrant ssh

# Using standard SSH (replace <ip> with actual IP)
ssh vagrant@<ip>
# Default password: vagrant
```

### Web Application Access
- From host machine: http://localhost:8080
- From VM: http://localhost

## Lab Components

### Directory Structure
```
/var/www/vuln_app/      - Vulnerable web application
/usr/local/bin/         - SUID binary location
/var/log/audit/         - SELinux audit logs
/home/vagrant/          - Lab instructions and tools
```

### Security Components
- SELinux in enforcing mode
- Audit daemon (auditd)
- Custom SUID binary
- Vulnerable web application
- Security monitoring scripts

## Running the Lab Exercises

### 1. Initial Reconnaissance
```bash
# Test web application
curl http://localhost:8080/?cmd=id

# List system binaries
curl http://localhost:8080/?cmd=ls+-la+/usr/local/bin

# Search for SUID binaries
curl http://localhost:8080/?cmd=find+/+-perm+-4000+2>/dev/null
```

### 2. Privilege Escalation Attempt
```bash
# Execute SUID binary
curl http://localhost:8080/?cmd=/usr/local/bin/suid_demo

# Try to access protected files
curl http://localhost:8080/?cmd=cat+/root/flag.txt
```

### 3. Security Monitoring

#### Generate Security Report
```bash
cd /home/vagrant
./generate_report.sh
```

#### Monitor SELinux Events
```bash
# View real-time alerts
sudo tail -f /var/log/audit/audit.log

# Check SELinux status
sestatus

# View SELinux alerts
sudo sealert -a /var/log/audit/audit.log
```

## Understanding the Outputs

### SELinux Denials
```bash
# Format of typical denial
type=AVC msg=audit(timestamp): avc: denied { action } for pid=XX 
comm="process_name" path="/path/to/file" ...
```

### Security Reports
The generated reports include:
- SELinux denial events timeline
- Privilege escalation attempts
- Web application exploitation attempts
- Detailed SELinux alerts
- File access violations with explanations

## Troubleshooting

### Common Issues
1. **VM fails to start**
   ```bash
   # Check VMware tools status
   vagrant plugin list
   vagrant plugin install vagrant-vmware-desktop
   ```

2. **Web application inaccessible**
   ```bash
   # Check nginx status
   sudo systemctl status nginx
   
   # Check SELinux contexts
   sudo ps -eZ | grep nginx
   ```

3. **SELinux issues**
   ```bash
   # Check SELinux status
   getenforce
   
   # View SELinux boolean settings
   getsebool -a | grep httpd
   ```

## Cleanup

Remove the lab environment:
```bash
vagrant destroy -f
```

## Security Notice

⚠️ **Warning**: This lab contains intentionally vulnerable components for educational purposes. Do not deploy or use these components in production environments.

## Demonstration Commands

Follow these commands step by step to simulate attacks and then review alerts and logs:

1. Start the lab environment:
```bash
cd src
vagrant up
```

2. SSH into the VM:
```bash
vagrant ssh
```

3. Exploit the vulnerable web application:
```bash
curl "http://localhost:8080/?cmd=id"
curl "http://localhost:8080/?cmd=/usr/local/bin/suid_demo"
curl "http://localhost:8080/?cmd=cat+/root/flag.txt"
```

4. Check the recent audit logs:
```bash
sudo tail -n 50 /var/log/audit/audit.log
```

5. Run the alert check script to see privilege escalation and SUID modification alerts:
```bash
sudo /usr/local/bin/check_alerts
```

6. Generate a detailed security report using log analysis tools:
```bash
cd /home/vagrant
./generate_report.sh
```

7. Verify the generated security report:
```bash
ls -ltr ~/security_report_*.txt
```
