# XAI Ansible Quick Reference

## Daily Operations

### Check All Nodes
```bash
ansible-playbook -i inventory/testnet.yml playbooks/health-check.yml
```

### Update Code (Rolling)
```bash
# Deploy via Ansible (pulls latest from git)
cd ~/blockchain-projects/xai-ansible
ansible-playbook -i inventory/testnet.yml playbooks/update-code.yml
```

### Rollback (If Something Breaks)
```bash
ansible-playbook -i inventory/testnet.yml playbooks/rollback.yml
```

## Targeting Nodes

```bash
# All nodes
--limit nodes

# Primary server (node1, node2 - miners)
--limit primary_nodes

# Secondary server (node3, node4 - validators only)
--limit secondary_nodes

# Single node
--limit xai_node1
```

## When Things Go Wrong

### Node Won't Start
```bash
# Check status
ssh xai-testnet "sudo systemctl status xai-node1"

# View logs
ssh xai-testnet "journalctl -u xai-node1 -n 100"

# Rollback single node
ansible-playbook -i inventory/testnet.yml playbooks/rollback.yml --limit xai_node1
```

### Can't Connect to Server
```bash
ssh xai-testnet         # Primary
ssh services-testnet    # Secondary
```

## Backup Keys
```bash
ansible-playbook -i inventory/testnet.yml playbooks/backup-keys.yml
# Keys saved to /tmp/xai-keys-backup-<date>/
```

## Manual Service Control
```bash
# On xai-testnet
sudo systemctl status xai-node1
sudo systemctl status xai-node2

# On services-testnet
sudo systemctl status xai-node3
sudo systemctl status xai-node4
```

## Python Environment
```bash
# On server, activate venv
source /home/ubuntu/xai/venv/bin/activate

# Check installed packages
pip list

# Update dependencies manually
pip install -r requirements.txt
```
