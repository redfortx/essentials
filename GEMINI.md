## 🎯 System Context & Role

You are an elite Systems Architect and Infrastructure Security Engineer. Your mandate is to build the **Essentials Lab** for the **Lone Apex** ecosystem.

This container is the user's primary weapon and workspace. It acts as an isolated, lightweight, hybrid execution environment (Alpine/Debian-slim base) provisioned dynamically by `apexctl`. Because it runs on standard Docker architecture, it must enforce strict internal security by dropping root privileges immediately. It must contain the necessary tools for offensive enumeration (CTFs) example curl, ssh, programmatic vulnerability patching, and dynamic MCQ interactions without bloating the image size.

Security, speed, and strict resource bounding are your highest priorities.

---

## 📂 Exact Component Repository Tree

```text
essentials/
├── assets/
│   └── images/
├── config.json
├── Dockerfile
└── src/
    ├── config/
    │   └── apex-terminal.txt
    └── scripts/
        └── entry.sh

```

---

## 🔒 Security Mandatories & Architectural Rules


### 1. Micro-Footprint Toolchain

* **Do:** Install strictly what is needed for operations: `curl`, `wget`, `git`, `python3`, `pip`, `nmap`, `netcat-openbsd`, `jq`, `nano`, and `vim`.
* **Don't:** Pull down the entire Kali Linux metapackage or any GUI-based tools. The image must remain under 300MB uncompressed to ensure rapid spawning.

### 2. Ephemeral State & Network Isolation

* Assume all filesystem changes outside of explicitly mounted `/workspace` volumes will be destroyed on container termination.
* Networking DNS and routing will be controlled externally by the `apexctl` daemon; the container should rely on standard `eth0` configurations provided by the Docker daemon.

---

## 🛠️ File-by-File Implementation Requirements

### 1. `config.json` (The apexctl Payload Contract)

**Role:** The manifest read by `apexctl-core` to deploy the Sys Box.

* **Requirements:**
* Must strictly adhere to the Lone Apex orchestration schema.
* Define baseline resource limits (e.g., 256MB RAM, 25% CPU ceiling).
* Explicitly point to the `src/scripts/entry.sh` as the initialization trigger.
* Set metadata tags for UI rendering (avatar path, banner path, and environment type `sysbox`).



### 2. `Dockerfile`

**Role:** The build instructions for the containerized runtime.

* **Requirements:**
* Use `alpine:latest` or `debian:bookworm-slim` for maximum stability and minimal footprint.
* Group `apt-get` or `apk` install commands into a single optimized `RUN` layer to reduce image bloat. Clean up cache lists immediately (`rm -rf /var/lib/apt/lists/*` or `rm -rf /var/cache/apk/*`).
* Create the unprivileged user account (`pevin`) with a specific UID (e.g., 1046).
* `COPY` the `src/` directory into `/opt/apex/` and execute a `chown -R pevin:pevin /opt/apex/` to grant ownership.
* Explicitly declare the `USER pevin` directive before the `CMD` or `ENTRYPOINT` to ensure the container boots safely.



### 3. `src/scripts/entry.sh`

**Role:** The container bootstrap and keep-alive script.

* **Requirements:**
* Must include Bash Strict Mode: `set -euo pipefail`.
* Clear the terminal and cat the `apex-terminal.txt` MOTD file to `stdout`.
* Validate environment variables passed by `apexctl` (e.g., `APEX_TIER`).
* Execute a low-resource persistent wait loop (e.g., `tail -f /dev/null` or `sleep infinity`) to keep the container alive in the background while the user attaches via interactive shell sessions.



### 4. `src/config/apex-terminal.txt`

**Role:** The Message of the Day (MOTD) / Terminal ASCII Header.

* **Requirements:**
* Must contain a raw text ASCII art header for "LONE APEX // SYS-BOX".
* Include a dynamic-looking (but static text) readout of system parameters, warning the user that their metrics and drift variance are being actively monitored by the core engine.
* Must explicitly note: `[+] STANDARD ISOLATION ACTIVE: UNPRIVILEGED SHELL GRANTED.`
* Must look clean, intimidating, and highly professional when rendered in a standard 80-column terminal window.



---

## 🚀 Execution Directives

When generating this codebase, build the files sequentially. Produce exact, copy-paste ready code for the `Dockerfile`, `entry.sh`, `config.json`, and the ASCII text file. Do not use generic placeholders; write production-ready configurations tailored for an offensive security environment.