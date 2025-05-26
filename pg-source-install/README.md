# Install PostgreSQL from Source

## Prerequisites

- **Multipass installed**

> *Multipass is a CLI to launch and manage VMs on Windows, macOS, and Linux. It simulates a clean Ubuntu cloud environment ideal for local testing and builds.*

- macOS:  
  ```bash
  brew install --cask multipass
  ```

- Windows:  
  [Download Multipass for Windows](https://multipass.run/download/windows)

---

## Preparation: Start the VM

### Launch a Fresh Ubuntu VM

```bash
multipass launch --name pg-source --memory 4G --disk 10G
```

- `--memory 4G`: 
  - Compiling PostgreSQL uses multiple threads and temporary memory.
  - The PostgreSQL server allocates shared buffers and background processes even in minimal setups.
  - 2 GB might work but can lead to long compile times or out-of-memory errors.
  - 4 GB ensures a smoother and faster build process, even with optional features like ICU.

- `--disk 10G`: 
  - The extracted source code alone can take ~100–200 MB.
  - The compiled binaries and intermediate object files can exceed 2–3 GB.
  - Installing additional build dependencies also consumes space.
  - 10 GB ensures there's ample room for building, logging, and experimenting safely.

---

### Access the VM

```bash
multipass shell pg-source
```

This opens a terminal into the VM — like SSH but simpler.

> 💡 Other useful `multipass` commands:
>
> - `multipass list` – Show all instances  
> - `multipass stop pg-source` – Stop the VM  
> - `multipass start pg-source` – Start the VM  
> - `multipass delete pg-source` – Delete the VM  
> - `multipass purge` – Remove deleted VMs and free disk space

---

## Installation Guide

### 1. Install Required Build Tools & Libraries

Run the following to install all necessary build dependencies:

```bash
sudo apt update
sudo apt install -y build-essential libreadline-dev zlib1g-dev flex bison pkg-config libicu-dev
```

Explanation of each package:

- **`build-essential`**  
  Installs core tools like `gcc` (a C compiler) and `make` (a build orchestrator) needed to compile PostgreSQL from source.

- **`libreadline-dev`**  
  Enables command-line editing features in `psql` (arrow keys, history, etc.).  
  Without it, the `psql` shell is very limited.

- **`zlib1g-dev`**  
  Adds support for compression — used internally by PostgreSQL for features like **TOAST** (for large field storage) and **WAL** (Write-Ahead Logging for durability).

- **`flex`**  
  Generates lexical analyzers — used to tokenize SQL input before parsing.

- **`bison`**  
  Generates the SQL parser from grammar definitions — essential for building PostgreSQL’s SQL engine.

- **`pkg-config`**  
  Assists the `configure` script in finding available libraries and their settings — required to detect optional features like ICU.

- **`libicu-dev`**  
  Enables **ICU** (International Components for Unicode), which provides proper multilingual collation and Unicode-aware string comparison in PostgreSQL.

> ✅ Without these packages, the build will fail or PostgreSQL will be compiled without important capabilities like Unicode support, compression, or SQL parsing.

---

### 2. Download PostgreSQL Source

You can either download a **release archive** or **clone the Git repository**.

#### Option A: Download Official Release Archive

```bash
wget https://ftp.postgresql.org/pub/source/v17.5/postgresql-17.5.tar.gz
tar -xzf postgresql-17.5.tar.gz
cd postgresql-17.5
```

✅ Best for stable builds  
❌ Not ideal for switching versions

---

#### Option B: Clone the Git Repository

```bash
git clone https://github.com/postgres/postgres.git
cd postgres
git tag -l "REL_*" | sort -Vr | head -n 20
git checkout REL_17_5
```

✅ Great for testing or developing against specific versions  
❌ Larger download and slightly longer build

---

No matter which option you chose, you should now be inside a PostgreSQL source directory.  
Key files and folders include:

```
configure         # Script to prepare the build system
Makefile          # Top-level build instructions
src/              # Core source code for PostgreSQL
contrib/          # Optional modules and extensions
doc/              # Documentation (used if building docs)
```

---

### 3. Configure the Build System

```bash
./configure --prefix=/usr/local/pgsql
```

- Prepares the Makefiles and checks for dependencies
- `--prefix` sets the install path

> 💡 For local installs, use `--prefix=$HOME/pgsql` instead.

---

### 4. Compile the Source Code

```bash
make -j$(nproc)
```

> 💡 This uses all CPU cores for faster compilation. Use `make -j4` to limit to 4 threads.

---

### 5. Install the Binaries

```bash
sudo make install
```

Check:

```bash
ls /usr/local/pgsql/bin
/usr/local/pgsql/bin/psql --version
```

---

### 6. Create the PostgreSQL User and Data Directory

```bash
sudo useradd -m postgres
sudo mkdir /usr/local/pgsql/data
sudo chown postgres /usr/local/pgsql/data
```

#### 📘 About this layout

| Benefit        | Explanation                                                                 |
|----------------|-----------------------------------------------------------------------------|
| 🔒 Isolation    | Keeps everything under `/usr/local/pgsql`                                   |
| 📦 Easy cleanup | Remove the entire install with `rm -rf`                                     |
| ⚙️ Simplicity   | `initdb` defaults to `$prefix/data`                                         |
| 🧪 Dev-friendly | Great for switching between PostgreSQL versions                             |

---

### 7. Initialize the Database Cluster

```bash
sudo su - postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
```

Then exit:

```bash
exit
```

---

### 8. Start the PostgreSQL Server

```bash
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start
```

Verify:

```bash
/usr/local/pgsql/bin/psql -l
```

Stop:

```bash
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data stop
```

---

### 9. Connect to the PostgreSQL Server (psql)

```bash
/usr/local/pgsql/bin/psql
```

Try:

```sql
SELECT version();
CREATE DATABASE testdb;
\c testdb
\q
```

---

### 10. Configure the Environment for the `postgres` User

#### Step 1: Set Bash shell (if not already)

```bash
sudo chsh -s /bin/bash postgres
```

#### Step 2: Set PATH and PGDATA

```bash
echo 'export PATH=/usr/local/pgsql/bin:$PATH' | sudo tee -a ~postgres/.bash_profile
echo 'export PGDATA=/usr/local/pgsql/data' | sudo tee -a ~postgres/.bash_profile
```

#### Step 3: Apply changes

```bash
sudo -i -u postgres
```

Then test:

```bash
pg_ctl status
psql
```

---

### 11. Configuration Files and Log Location

```bash
nano /usr/local/pgsql/data/postgresql.conf
```

> 📄 Also see:  
> - `pg_hba.conf` — authentication  
> - `pg_ident.conf` — role mapping

To view logs:

```bash
tail -f logfile
```

---

### 12. Start PostgreSQL Automatically (Optional)

> 💡 **About `systemd` and `systemctl`**
>
> `systemctl` is used to manage services:
>
> - `start`, `stop`, `restart`, `status`
> - `enable` (start at boot)
> - `disable` (don’t start at boot)

---

#### Step 1: Create the systemd unit

```bash
sudo nano /etc/systemd/system/postgresql-source.service
```

Paste:

```ini
[Unit]
Description=PostgreSQL (source build)
After=network.target

[Service]
Type=forking
User=postgres
ExecStart=/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l /usr/local/pgsql/data/server.log start
ExecStop=/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data stop
ExecReload=/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data reload
PIDFile=/usr/local/pgsql/data/postmaster.pid

[Install]
WantedBy=multi-user.target
```

---

#### Step 2: Enable and start the service

```bash
sudo systemctl daemon-reexec
sudo systemctl enable postgresql-source
sudo systemctl start postgresql-source
```

Check:

```bash
sudo systemctl status postgresql-source
```

---

#### Step 3: Check server log

```bash
sudo tail -n 20 /usr/local/pgsql/data/server.log
```

---

#### Step 4: Connect

```bash
sudo -i -u postgres
psql
\q
```

---

#### 🧪 After Reboot (or Multipass Restart)

```bash
multipass restart pg-source
multipass exec pg-source -- systemctl status postgresql-source
```

Look for:

```
Active: active (running)
```

---
