# XAI Ansible Infrastructure

Ansible automation for XAI blockchain testnet deployment and operations.

## Design Philosophy

This playbook collection follows **blockchain community conventions**:

- **Multiple small playbooks** - One playbook per operation, not monolithic
- **`support_*.yml` naming** - Operational playbooks follow Polkachu/Cosmos standard
- **Role-based architecture** - Reusable components in `roles/`
- **Separate inventories** - Per-network configuration
- **Group variables** - Shared config in `group_vars/`, per-host in `host_vars/`

## TL;DR - Quick Start

```bash
# Install dependencies
ansible-galaxy install -r requirements.yml

# First-time server setup (security hardening)
ansible-playbook -i inventory/testnet.yml setup.yml

# Deploy XAI nodes
ansible-playbook -i inventory/testnet.yml main.yml

# Fast sync a stalled node
ansible-playbook -i inventory/testnet.yml support_state_sync.yml --limit xai_val1

# Check node health
ansible-playbook -i inventory/testnet.yml playbooks/health-check.yml
```

## Architecture

### Network Topology

```
                    PUBLIC INTERNET
                          │
                   ┌──────┴──────┐
                   │   NGINX LB  │
                   │  Cloudflare │
                   └──────┬──────┘
                          │
            ┌─────────────┴─────────────┐
            │      SENTRY NODES         │
            │   (Public DDoS Shield)    │
            │  sentry1 RPC:12570        │
            │  sentry2 RPC:12571        │
            └─────────────┬─────────────┘
                          │ WireGuard VPN (10.10.0.x)
            ┌─────────────┴─────────────┐
            │     VALIDATOR NODES       │
            │   (Private, Protected)    │
            │  val1-4 (mining/voting)   │
            └───────────────────────────┘
```

### Node Configuration

Topology: `[Val1, Val2] → Sentry1 ←→ Sentry2 ← [Val3, Val4]`

| Node | Server | Type | RPC | P2P | Service | Mining |
|------|--------|------|-----|-----|---------|--------|
| val1 | xai-testnet (10.10.0.3) | validator | 12545 | 12333 | xai-mvp-val1 | Yes |
| val2 | xai-testnet (10.10.0.3) | validator | 12555 | 12334 | xai-mvp-val2 | Yes |
| sentry1 | xai-testnet (10.10.0.3) | sentry | 12570 | 12371 | xai-sentry1 | No |
| val3 | services-testnet (10.10.0.4) | validator | 12546 | 12335 | xai-mvp-val3 | Yes |
| val4 | services-testnet (10.10.0.4) | validator | 12556 | 12336 | xai-mvp-val4 | Yes |
| sentry2 | services-testnet (10.10.0.4) | sentry | 12571 | 12372 | xai-sentry2 | No |

## Playbooks

### Primary Playbooks

| Playbook | Purpose | Usage |
|----------|---------|-------|
| `main.yml` | Deploy XAI nodes | `ansible-playbook -i inventory/testnet.yml main.yml` |
| `setup.yml` | Server security hardening | `ansible-playbook -i inventory/testnet.yml setup.yml` |

### Support Playbooks (Operations)

| Playbook | Purpose | Usage |
|----------|---------|-------|
| `support_state_sync.yml` | Fast sync using snapshots | `... support_state_sync.yml --limit xai_val1` |
| `support_restore.yml` | Restore from R2 snapshot | `... support_restore.yml --limit xai_val1` |
| `support_genesis_sync.yml` | Full sync from genesis | `... support_genesis_sync.yml -e confirm_genesis_sync=yes` |
| `support_snapshot.yml` | Create snapshots + cron | `... support_snapshot.yml --limit xai_val1` |
| `support_monitoring.yml` | Deploy metrics exporters | `... support_monitoring.yml` |
| `support_resync.yml` | Scheduled automatic recovery | `... support_resync.yml --limit xai_val1` |

### Node Lifecycle Management

These playbooks follow blockchain community standards for key management and node operations (Polkachu, EthStaker, Cosmos patterns).

| Playbook | Purpose | Usage |
|----------|---------|-------|
| `support_backup_keys.yml` | Encrypted key backup (GPG AES-256) | `... support_backup_keys.yml --limit xai_val1` |
| `support_restore_keys.yml` | Restore keys from encrypted backup | `... support_restore_keys.yml --limit xai_val1 -e backup_file=/path/to/backup.gpg` |
| `support_remove_node.yml` | Complete node removal with cleanup | `... support_remove_node.yml --limit xai_val1 -e confirm_removal=yes` |
| `support_migrate_node.yml` | Multi-phase node migration | `... support_migrate_node.yml -e source_host=xai_val1 -e target_host=xai_val5` |

### Legacy Playbooks (in playbooks/)

| Playbook | Purpose |
|----------|---------|
| `playbooks/health-check.yml` | Check node and service status |
| `playbooks/update-code.yml` | Rolling code update |
| `playbooks/backup-keys.yml` | Backup node keys/wallets |
| `playbooks/rollback.yml` | Rollback to previous commit |

## Directory Structure

```
ansible/
├── main.yml                    # Primary node deployment
├── setup.yml                   # Server security/preparation
├── support_state_sync.yml      # Fast sync operations
├── support_restore.yml         # Snapshot restore
├── support_genesis_sync.yml    # Full sync from genesis
├── support_snapshot.yml        # Snapshot creation + cron
├── support_monitoring.yml      # Metrics and alerting
├── support_resync.yml          # Scheduled automatic recovery
├── support_backup_keys.yml     # Encrypted key backup
├── support_restore_keys.yml    # Key restore from backup
├── support_remove_node.yml     # Complete node removal
├── support_migrate_node.yml    # Multi-phase migration
│
├── inventory/
│   └── testnet.yml             # Testnet node definitions
│
├── group_vars/
│   ├── all.yml                 # Global configuration
│   └── nodes.yml               # Node-specific defaults
│
├── host_vars/                  # Per-host overrides
│
├── roles/
│   ├── common/                 # Server hardening, packages
│   ├── xai_node/               # XAI Python node deployment
│   ├── monitoring/             # Prometheus, exporters
│   └── nginx/                  # Reverse proxy
│
├── templates/
│   └── xai-node.service.j2     # Systemd service template
│
├── playbooks/                  # Legacy/additional playbooks
│   ├── health-check.yml
│   ├── update-code.yml
│   ├── backup-keys.yml
│   └── rollback.yml
│
├── requirements.yml            # Galaxy dependencies
└── ansible.cfg                 # Ansible configuration
```

## Variables

### Global Variables (group_vars/all.yml)

| Variable | Default | Description |
|----------|---------|-------------|
| `chain_id` | `xai-mvp-testnet-1` | Chain identifier |
| `daemon_user` | `ubuntu` | System user for XAI |
| `venv_path` | `/home/ubuntu/xai/venv` | Python virtualenv |
| `vpn_network` | `10.10.0.0/24` | WireGuard VPN CIDR |
| `node_exporter_port` | `9100` | Node exporter metrics |
| `xai_metrics_port` | `9302` | XAI custom metrics |

### Per-Host Variables (inventory)

| Variable | Required | Description |
|----------|----------|-------------|
| `node_name` | Yes | Node identifier (node1, sentry1, etc.) |
| `node_type` | Yes | Type: `node`, `validator`, `sentry` |
| `rpc_port` | Yes | RPC API port |
| `p2p_port` | Yes | P2P gossip port |
| `daemon_home` | Yes | Node data directory |
| `service_name` | Yes | Systemd service name |
| `mining` | No | Enable mining (default: false) |
| `miner_address` | No | Mining reward address |
| `peers` | No | List of peer URLs |

## Targeting Nodes

```bash
# All nodes
ansible-playbook -i inventory/testnet.yml main.yml

# Primary server only (miners + sentries)
ansible-playbook -i inventory/testnet.yml main.yml --limit 'primary_nodes:primary_sentries'

# Secondary server only (validators)
ansible-playbook -i inventory/testnet.yml main.yml --limit secondary_nodes

# Single node
ansible-playbook -i inventory/testnet.yml main.yml --limit xai_val1

# Sentries only
ansible-playbook -i inventory/testnet.yml main.yml --limit 'xai_sentry1:xai_sentry2'
```

## Common Operations

### Deploy New Node

```bash
# 1. Setup server (first time only)
ansible-playbook -i inventory/testnet.yml setup.yml --limit xai_val1

# 2. Deploy node
ansible-playbook -i inventory/testnet.yml main.yml --limit xai_val1

# 3. Fast sync from snapshot
ansible-playbook -i inventory/testnet.yml support_state_sync.yml --limit xai_val1
```

### Recover Stalled Node

```bash
# Check current status
ansible-playbook -i inventory/testnet.yml playbooks/health-check.yml --limit xai_val1

# Force state sync
ansible-playbook -i inventory/testnet.yml support_state_sync.yml --limit xai_val1 -e force_snapshot=true
```

### Create Snapshot

```bash
# One-time snapshot
ansible-playbook -i inventory/testnet.yml support_snapshot.yml --limit xai_val1

# Setup daily cron
ansible-playbook -i inventory/testnet.yml support_snapshot.yml --limit xai_val1 -e enable_cron=true
```

### Full Genesis Sync (Archive Node)

```bash
# WARNING: Takes a long time!
ansible-playbook -i inventory/testnet.yml support_genesis_sync.yml --limit xai_val1 -e confirm_genesis_sync=yes
```

### Backup Node Keys

```bash
# Backup with password prompt (encrypted GPG AES-256)
ansible-playbook -i inventory/testnet.yml support_backup_keys.yml --limit xai_val1

# Backup to custom location
ansible-playbook -i inventory/testnet.yml support_backup_keys.yml --limit xai_val1 \
  -e backup_dest=/secure/backups
```

### Restore Node Keys

```bash
# Restore from encrypted backup
ansible-playbook -i inventory/testnet.yml support_restore_keys.yml --limit xai_val1 \
  -e backup_file=/path/to/backup.tar.gz.gpg

# Restore without starting node (for pre-staging)
ansible-playbook -i inventory/testnet.yml support_restore_keys.yml --limit xai_val1 \
  -e backup_file=/path/to/backup.tar.gz.gpg -e start_node=false
```

### Remove a Node

```bash
# Remove with confirmation prompt
ansible-playbook -i inventory/testnet.yml support_remove_node.yml --limit xai_val1

# Remove with archival (preserve data)
ansible-playbook -i inventory/testnet.yml support_remove_node.yml --limit xai_val1 \
  -e archive_data=true -e confirm_removal=yes

# Remove but keep keys
ansible-playbook -i inventory/testnet.yml support_remove_node.yml --limit xai_val1 \
  -e preserve_keys=true -e confirm_removal=yes
```

### Migrate Node to New Server

```bash
# Full migration (backup → stop → sync → restore → verify)
ansible-playbook -i inventory/testnet.yml support_migrate_node.yml \
  -e source_host=xai_val1 -e target_host=xai_val5

# Migration without removing source (for testing)
ansible-playbook -i inventory/testnet.yml support_migrate_node.yml \
  -e source_host=xai_val1 -e target_host=xai_val5 -e cleanup_source=false
```

### Scheduled Automatic Recovery

```bash
# Install weekly resync cron (Sunday 3am)
ansible-playbook -i inventory/testnet.yml support_resync.yml --limit xai_val1

# Custom schedule with Slack notifications
ansible-playbook -i inventory/testnet.yml support_resync.yml --limit xai_val1 \
  -e resync_hour=4 -e resync_weekday='*' -e slack_webhook=https://hooks.slack.com/...

# Immediate resync (run now)
ansible-playbook -i inventory/testnet.yml support_resync.yml --limit xai_val1 \
  -e run_now=true -e install_cron=false
```

## SSH Access

```bash
ssh xai-testnet        # Primary server (54.39.129.11)
ssh services-testnet   # Secondary server (139.99.149.160)
```

## Service Management

```bash
# Check status
sudo systemctl status xai-mvp-val1

# Restart node
sudo systemctl restart xai-mvp-val1

# View logs
journalctl -u xai-mvp-val1 -f --no-hostname

# Quick health check
curl -s http://127.0.0.1:12545/stats | jq '{height:.chain_height,peers:.peer_count}'
```

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.xaiblockchain.com |
| API | https://testnet-api.xaiblockchain.com |
| WebSocket | wss://testnet-ws.xaiblockchain.com |
| Explorer | https://testnet-explorer.xaiblockchain.com |
| Faucet | https://testnet-faucet.xaiblockchain.com |
| Artifacts | https://artifacts.xaiblockchain.com |

## Acknowledgements

Structure inspired by:
- [Polkachu cosmos-validators](https://github.com/polkachu/cosmos-validators)
- [Cosmos-Spaces ansible-cosmos-validators](https://github.com/cosmos-spaces/ansible-cosmos-validators)
- [Hypha Coop cosmos-ansible](https://github.com/hyphacoop/cosmos-ansible)
