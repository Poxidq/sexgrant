#!/usr/bin/env python3
import json
import subprocess
import sys
import time

def get_vagrant_ssh_config():
    # Add retry mechanism
    max_attempts = 5
    attempt = 0
    while attempt < max_attempts:
        try:
            result = subprocess.run(
                ["vagrant", "ssh-config"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True
            )
            return result.stdout
        except subprocess.CalledProcessError as e:
            attempt += 1
            if attempt < max_attempts:
                time.sleep(10)  # Wait 10 seconds before retry
            else:
                sys.stderr.write(f"Error after {max_attempts} attempts: {e.stderr}\n")
                sys.exit(1)

def parse_ssh_config(config):
    host_info = {
        "ansible_host": "127.0.0.1",
        "ansible_port": 2222,
        "ansible_user": "vagrant",
        "ansible_private_key_file": ".vagrant/machines/default/vmware_desktop/private_key",
        "ansible_python_interpreter": "/usr/bin/python3"
    }
    
    for line in config.split('\n'):
        if 'HostName' in line:
            host_info['ansible_host'] = line.split()[-1]
        elif 'Port' in line:
            host_info['ansible_port'] = int(line.split()[-1])
        elif 'IdentityFile' in line:
            host_info['ansible_private_key_file'] = line.split()[-1].strip('"')
    
    # Modified inventory structure
    return {
        "all": {
            "hosts": ["default"],
            "vars": {}
        },
        "_meta": {
            "hostvars": {
                "default": host_info
            }
        }
    }

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        # Wait a bit to ensure the VM is fully up
        time.sleep(5)
        print(json.dumps(parse_ssh_config(get_vagrant_ssh_config())))
    elif len(sys.argv) == 3 and sys.argv[1] == '--host':
        # Return empty dict for --host as per Ansible spec
        print(json.dumps({}))
    else:
        sys.stderr.write("Usage: --list or --host <host>\n")
        sys.exit(1)