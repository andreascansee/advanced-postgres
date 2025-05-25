# PostgreSQL Upgrade (15 → 17): Local Testing Workflow with Multipass

> This guide walks you through upgrading PostgreSQL 15 to PostgreSQL 17 in a clean, isolated environment.
>
> You'll set up a Multipass virtual machine running **Ubuntu** with with an older PostgreSQL version (15 in this case) installed using a fully scripted, repeatable process. Then you'll perform a `pg_upgrade` to migrate to a newer version (17 here), preserving all existing data. I'll guide you through every configuration step required to ensure the upgrade works reliably.
>
> While this example uses versions 15 and 17, the same approach can be adapted for other version upgrades as well.
>
> If you're working in a different environment (e.g. Debian, CentOS, Docker, or a cloud-based setup), or preparing for a live upgrade of a real system, it's best to adapt this process to match your actual platform and constraints — ideally in a dedicated test environment before touching real data.
>
> Still, this demo gives you a clear and practical foundation for understanding what an upgrade involves and what details you'll need to watch for in your own setup.

## 🧰 Project Structure

```
scripts/
├── install/ # PostgreSQL installation scripts (15 and 17)
├── provision/ # VM provisioning script
├── seed/ # Data initialization + role + grant scripts
├── cleanup.sh # Stop, delete, and purge the VM
data/ # Ordered .sql files to define schema and seed data
vm.conf # Central config for VM
```

## ⚙️ Prerequisites

- [Multipass](https://multipass.run) installed

## 🛠️ Setup

In this section, you'll configure PostgreSQL inside a Multipass Ubuntu VM to simulate a server running an outdated version (PostgreSQL 15). This environment gives you a realistic foundation to practice version upgrades.

You'll also populate a test database with structured sample data to simulate a real-world application, including users, organizations, projects, and tasks. All setup steps are fully scripted and idempotent, so you can re-run them safely at any time.

### 🚀 1. Provision the PostgreSQL 15 VM

This creates a VM, installs PostgreSQL 15, and prepares it for upgrade:

```bash
bash scripts/provision/provision_vm_pg15.sh
```

> This script uses [`vm.conf`](scripts/vm.conf)
 to determine the VM name and resources.

### 💾 2. Seed initial data

```bash
bash scripts/seed/seed_data.sh
```
This step copies all [`*.sql` files from the `data/` directory](data/) into the VM's `/var/tmp/data` directory, which is readable by the `postgres` user (used to run the scripts) and writable by the `ubuntu` user (used for file transfer).


Then it executes the scripts in order:
- creating the database
- dropping/creating tables
- inserting seed data
- creating PostgreSQL roles
- applying permissions

> ℹ️ If you change the database name in [`data/00_init_db.sql`](data/00_init_db.sql), make sure to also update `DB_NAME="appdb"` in [`seed_data.sh`](scripts/seed/seed_data.sh) accordingly.

> ℹ️ Scripts are written to be idempotent and safe to rerun.

### ✅ 3. Validate and Explore the Setup
After provisioning and seeding, you can access the VM with:

```bash
multipass shell pg-upgrade   # multipass shell <vm-name>
```

To interact with the database, switch to a shell as the `postgres` user and launch `psql`:

```
sudo -i -u postgres
psql
```

This is required because PostgreSQL on Ubuntu uses **peer authentication** by default. Being the `postgres` system user ensures you're allowed to connect as the `postgres` database role.

Once inside `psql`, you can run standard introspection and navigation commands:

```sql
\l        -- list databases
\c appdb  -- connect to your test database
\dt       -- list tables
\du       -- list roles
\dn       -- list schemas
SELECT ...; -- run your queries
```

### 🧼 4. Clean up
Later, you can stop and delete the VM with:

```bash
bash scripts/cleanup.sh
```

## 🔁 Performing the Upgrade

With PostgreSQL 15 installed and seeded inside your VM, it's time to upgrade to PostgreSQL 17 — side-by-side, without touching our original data. This gives us full control and minimizes risk. The upgrade will preserve all data and settings while transitioning to the newer version in a controlled way.

> ℹ️ We'll use PostgreSQL's built-in `pg_upgrade` tool, which is the **recommended and fastest method** to upgrade between major versions when the system layout allows it. 
>
> Unlike dump/restore methods, `pg_upgrade` copies internal catalogs and user data files directly — dramatically reducing downtime for large databases.

We'll walk through the process step-by-step:
1. Install PostgreSQL 17
2. Create the Target Cluster
3. Fix Config Layout and Permissions
4. Run Compatibility Checks
5. Perform the Actual Upgrade 

You'll work inside the same VM, running both versions in parallel (temporarily) to ensure a smooth migration.

### 🧱 1. Install PostgreSQL 17

We'll now install PostgreSQL 17 side-by-side with version 15 inside the same VM — without touching the original data.

> 📍 Start from your local shell, not inside the VM.

#### 🧰 Step 1.1: Transfer the install script
Transfer the install script into the VM:

```bash
multipass transfer scripts/install/install_pg17.sh pg-upgrade:/home/ubuntu
```

> This [script](scripts/install/install_pg17.sh) is structured analog to [`install_pg15.sh`](scripts/install/install_pg15.sh), which was used in the provisioning step before. Again, we place it in `/home/ubuntu`.

#### ⚙️ Step 1.2: Run the script inside the VM

Execute the script remotely:

```bash
multipass exec pg-upgrade -- bash /home/ubuntu/install_pg17.sh
```

This script:
- Adds the PostgreSQL APT repository (if not already present)
- Installs PostgreSQL 17
- Verifies that the new cluster is created with `pg_lsclusters`

> ℹ️ If you want to upgrade to a different version, adjust the [script](scripts/install/install_pg17.sh) accordingly.

#### ✅ Step 1.3: Verify that PostgreSQL 17 is installed

Even if the installation was successful, `pg_lsclusters` won't list PostgreSQL 17 yet, because no cluster for version 17 has been created at this point.

To verify that PostgreSQL 17 is actually installed, first enter the VM:

```bash
multipass shell pg-upgrade
```

Then check that both versions are installed:
```bash
ls /usr/lib/postgresql/
```
You should see two separate directories for `15` and `17`.

Next, check the default `psql` client version:
```
psql --version
```
You should see something that includes `17`, confirming that the `psql` binary from version `17` is now the default.

> ⚠️ Keep in mind you're still connected to the old server!

To verify that the old server (`15`) is still running:

```bash
sudo -i -u postgres
psql
SELECT version();
```

This should return something like: `PostgreSQL 15.x [...]`. This confirms that you're still connected to the PostgreSQL 15 cluster — which is expected for now.

---

### ⚙️ 2. Create an Empty PostgreSQL 17 Cluster

At this point, PostgreSQL 17 is installed, but no data directory (cluster) exists for it yet.

To create a new empty cluster for PostgreSQL 17, run the following inside the VM (as the Ubuntu user):

```bash
sudo pg_createcluster 17 main
```

This creates the directory `/var/lib/postgresql/17/main`, which `pg_upgrade` will use as the target location.

To verify that both clusters now coexist, run:

```
pg_lsclusters
```

You should see output that confirms:
- ✅ PostgreSQL 15 is up and running 🟢
- ✅ PostgreSQL 17 has been created but is stopped 🔴

> ⚠️ Do not start the 17 cluster — `pg_upgrade` requires it to be offline.

---

### 🩺 3. Fix Debian-Specific Configuration Layout

On Debian-based systems (like Ubuntu), PostgreSQL stores its configuration files under `/etc/postgresql/...`, separate from the actual data directory.  
However, `pg_upgrade` expects all relevant config files to live **inside the cluster's data directory** (e.g., `/var/lib/postgresql/<version>/main/`).  

We need to manually align the layout so `pg_upgrade` can find and use the right configs.

Run these commands inside the VM as the `ubuntu user`:

```bash
sudo cp /etc/postgresql/15/main/*.conf /var/lib/postgresql/15/main/
sudo cp /etc/postgresql/17/main/*.conf /var/lib/postgresql/17/main/
```

This copies the following configuration files into the respective data directories:

- `postgresql.conf` – Main server configuration
- `pg_hba.conf` – Authentication rules
- `pg_ident.conf` – User mapping for ident authentication
- `start.conf` – Tells Debian whether the cluster auto-starts
- `conf.d/` – Optional include directory
- `environment` – Optional file for setting environment variables at startup

> 💡 Important:
> Even if `conf.d/` is empty, it must be copied as well! If this directory is missing, PostgreSQL will fail to start due to the line `include_dir = 'conf.d'` in `postgresql.conf`.
> You could comment out that line, but this is **not recommended** — it changes the default behavior, which may confuse future tooling or upgrades.

---

### 🔻 4. Shut Down All PostgreSQL Clusters

Before running `pg_upgrade`, both clusters must be shut down — especially the old one (PostgreSQL 15), which `pg_upgrade` will read from directly.

Inside the VM, run:

```bash
sudo systemctl stop postgresql@15-main
sudo systemctl stop postgresql@17-main
```
> 💡 Even though the PostgreSQL 17 cluster hasn't been started yet, stopping it ensures no background processes interfere with the upgrade.

To verify that both clusters are shut down, run:

```bash
pg_lsclusters
```

You should now see both clusters listed with `Status: down`. This ensures that `pg_upgrade` can safely take over and start both clusters under its own control.

---

### 🧪 4. Run a Compatibility Check (`pg_upgrade --check`)

Before performing the actual upgrade, it's crucial to verify that your PostgreSQL 15 cluster is compatible with PostgreSQL 17.

This dry-run makes no changes — it simply checks everything needed for a successful upgrade.

Run the following inside the VM as the postgres user (`sudo -i -u postgres`):

```bash
/usr/lib/postgresql/17/bin/pg_upgrade \
  --old-datadir=/var/lib/postgresql/15/main \
  --new-datadir=/var/lib/postgresql/17/main \
  --old-bindir=/usr/lib/postgresql/15/bin \
  --new-bindir=/usr/lib/postgresql/17/bin \
  --old-port=5432 \
  --new-port=5433 \
  --check
```
> 🧠 `pg_upgrade` requires both data directories and binary paths to properly compare internal formats and version metadata.
The port flags help prevent socket conflicts between clusters.

If everything is set up correctly, you should see this line at the end:

```
*Clusters are compatible*
```

This means you're ready to proceed with the real upgrade.

> 💡 **Troubleshooting Tip**
>
> `pg_upgrade` uses Unix domain sockets to temporarily start both clusters during the check.  
> If you see errors like `could not open configuration directory` or `socket connection failed`, you likely need to ensure the socket base is owned by `postgres`:
>
> ```bash
> sudo chown -R postgres:postgres /var/lib/postgresql
> ```

---

### 🚀 5.  Perform the Upgrade with `pg_upgrade`

You'll now run pg_upgrade for real, this time without the `--check` flag. This step will migrate all data from the PostgreSQL 15 cluster into the new PostgreSQL 17 cluster.

Run the following inside the VM as the `postgres` user (`sudo -i -u postgres`):

```bash
/usr/lib/postgresql/17/bin/pg_upgrade \
  --old-datadir=/var/lib/postgresql/15/main \
  --new-datadir=/var/lib/postgresql/17/main \
  --old-bindir=/usr/lib/postgresql/15/bin \
  --new-bindir=/usr/lib/postgresql/17/bin \
  --old-port=5432 \
  --new-port=5433
```

You'll see a detailed progress log. At the end, look for this line:

```bash
Upgrade Complete
```

At this point, PostgreSQL 17 has successfully taken over your data! 🎉

---

### 🟢 6. Verify the New Cluster

To confirm that PostgreSQL 17 is working as expected, connect to the new cluster on port `5433`:

```bash
sudo -u postgres psql -p 5433
```

Then run some checks:

Run some checks:

```bash
SELECT version();   -- should show PostgreSQL 17.x
\l                  -- list databases
\c appdb            -- connect to your upgraded test DB
\dt                 -- list tables
\du                 -- list roles
```

You should see all your original data, schema, and roles — now running under PostgreSQL 17.

---

### 🧼 7. Clean Up (optional)

#### 🗑️ Step 7.1: Delete the Old Cluster

After verifying everything works, you can delete the old PostgreSQL 15 data directory.
`pg_upgrade` generated a script to help with that:

```bash
sudo -i -u postgres
ls -l ~
# You should see: delete_old_cluster.sh
bash ~/delete_old_cluster.sh
exit
```

You can also remove the old cluster config directory:
```bash
sudo rm -rf /etc/postgresql/15/main
```
> ⚠️ Only delete the old cluster **after** verifying the new one works!

#### 🔁 Step 7.2: Switch Back to Port 5432

After the upgrade, the new PostgreSQL 17 cluster is still running on port `5433`.  
To make it the default again (on port `5432`), update its configuration.

First, locate the active config file. You can check the current process:

```bash
ps -ef | grep postgres
```

Look for a line like:
```
/usr/lib/postgresql/17/bin/postgres -D /var/lib/postgresql/17/main -c config_file=/etc/postgresql/17/main/postgresql.conf
```

Now edit that file:
```bash
sudo nano /etc/postgresql/17/main/postgresql.conf
```

Find the line (`Ctrl + W` to search): `port = 5433`. Change it to: `port = 5432`.

Then restart the PostgreSQL 17 cluster:

```bash
sudo systemctl restart postgresql@17-main
```

Verify the change:
```bash
pg_lsclusters
```

You should now see that the PostgreSQL 17 cluster is online on port 5432.

## 🧠 Additional Tips for Low-Impact Upgrades

While this guide focused on a manual side-by-side upgrade using `pg_upgrade`, here are a few important strategies to reduce downtime and improve upgrade safety in real-world scenarios:

### ✅ Use `--link` Mode to Avoid Full Data Copy
By default, `pg_upgrade` copies the entire data directory. For large databases, this takes time and disk space.  
Using `--link` avoids that by creating hard links instead:

```bash
pg_upgrade ... --link
```
> ⚠️ Be careful: this links both clusters to the same files. You must not use the old cluster afterward. Always take a backup first.

### ✅ Run pg_upgrade on a Standby First
If you're using streaming replication, you can:
- Stop the replica
- Upgrade it using `pg_upgrade`
- Promote it to primary after testing

This avoids downtime on the live server and allows a safe switchover.

### ✅ Pre-Warm the New Cluster
After upgrade, all PostgreSQL caches are cold. Consider warming up by:
- Running common queries
- Replaying some traffic in staging
- Running `pgbench` or scripted tests

This helps ensure consistent performance after going live.

### ✅ Plan for Schema Changes Separately

`pg_upgrade` is designed for **in-place version upgrades** — it does **not** handle schema migrations.

If your upgrade also involves schema changes (e.g. new columns, tables, indexes, renamed objects), you should **separate that step** from the actual upgrade:

1. **Upgrade first using `pg_upgrade`**, keeping the existing schema untouched.
2. **Deploy schema changes afterward** via migration scripts or tools like `sqitch`, `Flyway`, or `Liquibase`.
3. Apply schema changes in a **rolling or phased manner**, using techniques like:
   - Creating new tables/columns while keeping old ones temporarily
   - Writing to both schema versions ("dual write")
   - Reading from both until traffic is shifted

> 💡 This lets you roll forward or back independently, and keeps the upgrade process stable and focused.