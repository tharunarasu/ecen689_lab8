# ECEN 689 — Lab 8 Individual Report

**Student Name:** Saivarshan Sridharan 
**UIN:** 437004798 
**Team** 8 

---

## 1. What I personally did

* **CPU Core Compilation (Step 3):** Navigated directly into the `microwatt_src/` directory to build the Microwatt processor core from source.
* **Source Registration:** Ran `ghdl -i --std=08 $(cat ../lab8/core_files.txt)` to parse and import all 47 CPU VHDL source files into the GHDL work library in dependency order.
* **Core Elaboration and Compilation:** Executed `ghdl -m --std=08 core` to compile the full CPU entity (`core`).
* **Verification and Recording:** Checked the tool exit status by running `echo "CORE_MAKE_RC=$?"`, verified that the build succeeded with `CORE_MAKE_RC=0`, and recorded that line into `../lab8/answers.txt` for line **A1**.

---

## 2. Problems I encountered

When attempting to import the core sources in Step 3 inside `microwatt_src/`, the GHDL container wrapper crashed before reading the source files:

```
[saivarshan19@olympus-login microwatt_src]$ ghdl -i --std=08 $(cat ../lab8/core_files.txt)
WARNING: skipping mount of /var/tmp/saivarshan19: stat /var/tmp/saivarshan19: no such file or directory
FATAL:   container creation failed: mount /var/tmp/saivarshan19->/var/tmp/saivarshan19 error: while mounting /var/tmp/saivarshan19: mount source /var/tmp/saivarshan19 doesn't exist
[saivarshan19@olympus-login microwatt_src]$
```

Because the container failed during mount creation, GHDL aborted with an error and failed to register any design files.

---

## 3. How they were resolved

* **Diagnosis:**
  * I inspected the fatal line: `mount /var/tmp/saivarshan19->/var/tmp/saivarshan19 error: while mounting /var/tmp/saivarshan19: mount source /var/tmp/saivarshan19 doesn't exist`.
  * The `ghdl` command on `olympus-login` is wrapped in an container configured to bind mount `/var/tmp/$USER` from the host.
  * Because my user scratch directory had not been created on this login node, the container engine could not locate the source mount point and refused to launch.

* **Resolution Steps:**
  1. Created the missing directory on the host:
     ```bash
     mkdir -p /var/tmp/$USER
     ```
  2. Assigned standard user-only read/write/execute permissions:
     ```bash
     chmod 700 /var/tmp/$USER
     ```
  3. Confirmed directory existence with `ls -ld /var/tmp/$USER`.
  4. Re-executed the import command:
     ```bash
     ghdl -i --std=08 $(cat ../lab8/core_files.txt)
     ```
     The container mounted without warnings or fatal errors.
  5. Ran `ghdl -m --std=08 core`, which generated the binary model cleanly, and confirmed `CORE_MAKE_RC=0`.
