# ECEN 689 — Lab 8 Individual Report

**Student Name:** Saivarshan Sridharan 
**UIN:** 437004798 
**Team** 8 
---

## 1. What I personally did

* **Environment Setup (Step 1):** Connected via SSH to `olympus.ece.tamu.edu`, sourced the required toolchain environment script from `/mnt/nfs-scratch/ecen-689-nowka/kit/env.sh`, and appended the source line to `~/.bashrc` to ensure persistence across sessions.
* **Archive & Directory Unpack (Step 2):** Transferred the lab archive onto the host and unpacked the team workspace directory structure (`LAB8_MANUAL.md`, `lab8/`, `microwatt_src/`, `reports/`).
* **CPU Compilation (Step 3):** Navigated into `microwatt_src/`, imported all 47 VHDL source files into the GHDL work library via `ghdl -i --std=08 $(cat ../lab8/core_files.txt)`, and invoked `ghdl -m --std=08 core`. Observed and verified clean compilation with return code `CORE_MAKE_RC=0`, recording the line into `../lab8/answers.txt` (line A1).
* **Top-Level Configuration & Design (Step 4):** Copied `microwatt_top_skeleton.vhdl` to `microwatt_top.vhdl`. Using `nano`, I modified the `TEAM CONFIGURATION BLOCK` to set the core parameters (Menu M: `CFG_HAS_FPU := false;`, `CFG_ICACHE_NUM_LINES := 32;`, `CFG_DCACHE_NUM_LINES := 32;`), compiled the top-level entity with `ghdl -i --std=08 microwatt_top.vhdl` and `ghdl -m --std=08 microwatt_top`, and verified the resulting `DESIGN_OK team<N> menu=M` string for line A2.
* **Unit Simulation (Step 5):** Copied `multiply_tb_course.vhdl` into the working directory, analyzed and elaborated the multiplier testbench, and ran the simulation using `ghdl -r --std=08 multiply_tb_course`. Confirmed that all 7 directed test vectors passed with `SIM_RC=0` and recorded the confirmation to line A3.
* **Synthesis Execution & Monitoring (Step 6):** Returned to the root project directory `~/ecen689_lab8`, attempted Slurm job dispatch, managed queue blockers, transitioned to the background login-node synthesis flow via `bash lab8/synth_core_loginnode.sh`, and tracked live progress inside the tmux session using `tail -f synth_core_tmux.log`.

---

## 2. Problems I encountered

### Step 2 Archive Extraction & Terminal Stream Corruption
During Step 2, while attempting to unpack and inspect the archive structure, the binary archive stream was inadvertently redirected/output directly to standard out in the shell rather than extracted cleanly:
```text
ecen689_lab8/lab8/answers.txtux _s\[I 74`s [g7S M;@( ecen689_lab8/lab8/core_files.txtux 
ecen689_lab8/lab8/microwatt_top_skeleton.vhdlux `m$m |of8# CD74 ^$V, Cm3` [[SH Vq~d
ecen689_lab8/microwatt_src/dcache.vhdlux LOOOO? X:/7E oESg] WmW7 8?wrm 3:+- #k ]UiXLA
```
This flooded the active shell session with raw binary escape sequences, corrupting the terminal character mapping, font display, and command prompt visibility. Furthermore, files were initially not extracted into their expected relative directory hierarchy.


---

## 3. How they were resolved

### Resolution 1: Restoring Terminal State & Proper Extraction
* **Diagnosis:** Dumping compressed binary files to `stdout` transmitted non-printable control characters that corrupted the active terminal emulator's line discipline and character encoding settings.
* **Action:** 
  1. Issued the terminal initialization command `reset` to clear the terminal driver state and restore normal character echoing.
  2. Verified the presence of the compressed archive on the filesystem with `ls -l ecen689_lab8.zip`.
  3. Properly extracted the archive to disk using `unzip ecen689_lab8.zip`.
  4. Verified the intact folder hierarchy (`cd ecen689_lab8 && ls`) to confirm `LAB8_MANUAL.md`, `lab8/`, `microwatt_src/`, and `reports/` were in place before proceeding.
