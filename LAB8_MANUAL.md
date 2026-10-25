# ECEN 689 — Lab 8: Project Kickoff — Build Your Core Design
By the end of this lab your team has created its own CPU design (top-level +
configuration), simulated a CPU unit, and launched its first synthesis.

Follow the steps in order. Every step shows: what to type → what you must see →
what to record.


## What you are doing this semester (read once)

Your team takes Microwatt — a real, open-source POWER CPU written in VHDL —
through the complete chip-design flow to a final GDS layout (the file a factory
manufactures). **THE FRAME RULE: your final chip must fit the tapeout frame.
In practice your synthesized logic must stay under 5,800,000 µm² of cell
area** — you will measure your design against this number today, with a tool,
in Step 6. Everything else about evaluation is announced lab by lab.

## What you must deliver for THIS lab (summary)
1. `lab8/answers.txt` — filled with real tool output (A1–A6)
2. `microwatt_src/microwatt_top.vhdl` — your created design file
3. `synth_core_*.log` — your synthesis log
4. `reports/<name>.md` — **one individual report per member** (template provided):
   what you personally did, problems you hit, how they were resolved
5. One ZIP per team uploaded to Canvas (Step 7 builds it for you)

---

## Step 0 — Get the kit onto Olympus (one member, 5 min)

Download `ecen689_lab8.zip` from Canvas, then from your laptop:

scp ecen689_lab8.zip <netid>@olympus.ece.tamu.edu:

(Windows: run this in PowerShell from the folder containing the zip.)

## Step 1 — Log in + environment (each member, 10 min)
```bash
ssh <netid>@olympus.ece.tamu.edu
source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh
echo 'source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh' >> ~/.bashrc
```
**You must see:** `ECEN 689 ready.  ol <cmd> | lane <config>`

## Step 2 — Unpack (one member's account = the team workspace, 5 min)
```bash
unzip ecen689_lab8.zip
cd ecen689_lab8 && ls
```
**You must see:** `LAB8_MANUAL.md  lab8  microwatt_src  reports`
The team works together in this one folder (share the account owner's screen,
or work side by side — every member must personally run Steps 3–5 at least once,
in this folder or their own copy).

## Step 3 — Compile the entire CPU (10 min)

`ghdl -i` registers all sources; `ghdl -m core` compiles the full CPU in
dependency order automatically.
```bash
cd microwatt_src
ghdl -i --std=08 $(cat ../lab8/core_files.txt)
ghdl -m --std=08 core
echo "CORE_MAKE_RC=$?"
```
**You must see:** `CORE_MAKE_RC=0` (~1–2 min; warnings are OK, errors are not)
**Record** that line → `../lab8/answers.txt` line **A1**.
> **If it didn't work:** "cannot open <file>" → you are not inside
> `microwatt_src/`. Any VHDL error → you accidentally edited a source file;
> re-unzip or restore the file from the zip.

## Step 4 — CREATE YOUR DESIGN (30 min — the heart of this lab)

Your design = the chip's top level: it instantiates the Microwatt core with
**your configuration**. This file is yours for the rest of the semester.

**4a.** Create it from the course skeleton:
```bash
cp ../lab8/microwatt_top_skeleton.vhdl microwatt_top.vhdl
```
**4b.** Open `microwatt_top.vhdl` (any editor: `nano`, `vim`, VS Code Remote).
Find the marked block — you edit these three lines and NOTHING else:
```vhdl
    ----------------------------------------------------------------
    -- TEAM CONFIGURATION BLOCK - edit values below, nothing else
    ----------------------------------------------------------------
    constant CFG_HAS_FPU          : boolean := false;
    constant CFG_ICACHE_NUM_LINES : natural := 16;
    constant CFG_DCACHE_NUM_LINES : natural := 16;
```
**4c.** Pick your starting configuration from this menu (changeable later —
nothing is final today):

| Menu | HAS_FPU | ICACHE_NUM_LINES | DCACHE_NUM_LINES | Character |
| **S**| false   | 16               | 16               | smallest, safest — fits easily |
| **M** | false  | 32               | 32               | more cache — expected to fit |
| **L** | false  | 64               | 64               | big caches — fit NOT guaranteed; Step 6 decides |

(FPU stays false in all rows — Step 6 would show you an FPU design cannot fit
the frame. Custom values beyond the menu: allowed starting next lab.)

**4d.** Prove your design compiles:
```bash
ghdl -i --std=08 microwatt_top.vhdl
ghdl -m --std=08 microwatt_top && echo "DESIGN_OK team<N> menu=<S/M/L>"
```
**You must see:** your `DESIGN_OK` line (fill in your team/menu).
**Record** it → answers.txt line **A2**.
> **If it didn't work:** the error names a line in microwatt_top.vhdl — you
> edited outside the block or broke syntax (`:=` not `=`; every line ends `;`).
> Start over: `cp ../lab8/microwatt_top_skeleton.vhdl microwatt_top.vhdl`.

## Step 5 — Simulate a CPU unit (15 min)

The course testbench drives Microwatt's multiplier with directed tests and
checks every answer:
```bash
cp ../lab8/multiply_tb_course.vhdl .
ghdl -i --std=08 multiply_tb_course.vhdl
ghdl -m --std=08 multiply_tb_course
ghdl -r --std=08 multiply_tb_course
echo "SIM_RC=$?"
```
**You must see:** `ALL MULTIPLY TESTS PASSED (7 vectors)` then `SIM_RC=0`.
**Record** both lines → answers.txt line **A3**.

*Optional but recommended (10 min) — break it on purpose:* open `multiply.vhdl`
and find **line 66** (the add path the tests actually exercise):
```vhdl
v.multiply_pipeline(0).data := unsigned(m.addend) + unsigned(prod(127 downto 0));
```
Change that `+` to `-`, save, then rerun BOTH the compile and the run:
```bash
ghdl -m --std=08 multiply_tb_course && ghdl -r --std=08 multiply_tb_course
```
**You must see** failures with the exact bad values, e.g.
`MULTIPLY FAIL: 256 * 256 = -65536 (expected 65536)`. Restore the `+`, rerun,
confirm `ALL MULTIPLY TESTS PASSED` again. This break→observe→fix loop is the
core skill of the whole project.
*(Why line 66 and not the similar `-` on line 64? Line 64 is the subtract path —
our tests drive `subtract='0'`, so breaking it changes nothing. A test only
protects the code it actually executes: that is what "coverage" means, and why
you'll write more tests later.)*

## Step 6 — Synthesize YOUR design and measure it (launch now, finishes in ~1–2 h)

This converts your configured CPU into real silicon standard cells and prints
the exact area. Launch on the cluster:
```bash
cd ..            # back to the ecen689_lab8 folder
sbatch lab8/synth_core.sbatch
squeue -u $USER
```
**You must see:** `Submitted batch job <number>`.

> **If sbatch says "Invalid account":** use the fallback — identical result,
> runs politely on the login node:
> ```bash
> bash lab8/synth_core_loginnode.sh
> tail -f synth_core_tmux.log        # Ctrl-C stops watching, not the run
> ```
**Use the login node method if and only if the sbatch doesn't work and also update the TA if sbatch doesn't work, we need to make sure it works for later labs!!**

When the job finishes (check back later — it keeps running if you log out):
```bash
grep "Chip area for top module" synth_core_*.log | tail -1
```
**You must see:** `Chip area for top module '\microwatt_top': <NUMBER>`
**Record:** the number → **A4**, your menu letter → **A5**.

**THE FIT CHECK — the one decision of the day (record as A6):**
- A4 ≤ **5,800,000** → your design fits. A6 = YES.
- A4 > 5,800,000 → doesn't fit: switch to a smaller menu row, redo Step 4d,
  relaunch Step 6, record the new A4. A6 = YES only when it fits.

## Step 7 — Individual reports + submit (each member 15 min, then one upload)

**Each member** writes their own report — copy the template:
```bash
cp lab8/REPORT_TEMPLATE.md reports/<your_name>.md
nano reports/<your_name>.md      # fill all three sections following aggie honor code 
```
Then **one member** packages and submits:
```bash
bash lab8/make_submission_zip.sh <teamnumber>
```
**You must see:** `CREATED: .../lab8_team<N>_submission.zip` — the script checks
everything is present and refuses to package an incomplete submission (fix
whatever it lists as MISSING).

Download it to your laptop and upload to Canvas (one per team):

scp <netid>@olympus.ece.tamu.edu:~/ecen689_lab8/lab8_team<N>_submission.zip .

## Grading (100 pts = 60 team + 40 individual)

### Team score (60 pts — same for all members)
| Item | Evidence in submission | Pts |
|---|---|---|
| CPU source compiles | A1 line is real tool output, RC=0 | 5 |
| **Design created** | microwatt_top.vhdl present, compiles, config block edited correctly (nothing else changed) + A2 line | 15 |
| Unit simulation passes | A3 shows ALL MULTIPLY TESTS PASSED + SIM_RC=0 | 10 |
| Synthesis completed | synth_core log in zip, A4 area + A5 menu recorded | 15 |
| Fit-check decision | A6 correct vs. the 5,800,000 limit (incl. switching rows if needed) | 5 |
| Submission hygiene | zip built by the script, complete, on time, answers legible | 10 |

### Individual score (40 pts — from YOUR report, graded per member)
| Section of reports/<name>.md | What earns points | Pts |
|---|---|---|
| 1. What I personally did | Specific and verifiable (which steps you drove, what you typed/observed) — not "we did the lab" | 15 |
| 2. Problems I encountered | Real error lines pasted; "no problems" requires describing what you checked to be sure | 10 |
| 3. How they were resolved | The diagnosis path, not just the fix ("read X log, saw Y, concluded Z") | 15 |

A missing individual report = 0/40 for that member — the team 60 is unaffected.
Reports that are near-copies of a teammate's earn both reports a flag.


