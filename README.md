# Ubuntu Server Scripts

A collection of bash scripts for managing an Ubuntu server — backups, system monitoring, and GPU configuration.

## Scripts

### Backups (`backups/`)

Rsync-based backup scripts that sync to a remote NFS destination (e.g., TrueNAS).

| Script | Description |
|---|---|
| `backup-home.sh` | Backs up `/home/$USER/` to a date-stamped directory on the destination |
| `backup-data.sh` | Syncs `/data/` to the destination (uses `--delete` to mirror exactly) |

Both scripts:
- Read `DEST_DIR` and `LOG_FILE` from a `.env` file (see `.env.example`)
- Use an `exclude-list.txt` to skip files/directories (see `exclude-list.txt.example`)
- Set group ownership to `truenas` on copied files
- Are designed to be symlinked into `/usr/local/bin/` for easy execution

**Setup:**
```bash
cp backups/.env.example backups/.env    # Edit with your destination path and log file
cp backups/exclude-list.txt.example backups/exclude-list.txt  # Customize exclusions
sudo ln -s "$(pwd)/backups/backup-home.sh" /usr/local/bin/backup-home
sudo ln -s "$(pwd)/backups/backup-data.sh" /usr/local/bin/backup-data
```

### Monitoring (`monitoring/`)

| Script | Description |
|---|---|
| `system-monitor.sh` | Reports memory usage, top 5 CPU processes, disk usage, and uptime |

Outputs to both stdout and a log file. Reads `LOG_FILE` from `.env` (see `.env.example`).

**Setup:**
```bash
cp monitoring/.env.example monitoring/.env  # Edit with your log file path
sudo ln -s "$(pwd)/monitoring/system-monitor.sh" /usr/local/bin/system-monitor
```

### GPU (`undervolt.sh`)

Sets power and clock limits for an NVIDIA RTX 5090:
- Enables persistence mode
- Power limit: 540W
- Clock range: 2500–2700 MHz

```bash
sudo ./undervolt.sh
```

### Templates (`templates/`)

`bash_template.sh` — a starter template for new scripts with standard header, variables, functions, and logging pattern.

## Configuration

Each script directory uses its own `.env` file for configuration. `.env` files and `exclude-list.txt` are gitignored — use the provided `.example` files as a starting point.
