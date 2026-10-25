#!/bin/bash
# Fallback if sbatch fails ("Invalid account"): runs politely on the login node. ~1-2 h.
source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh
cd "$(dirname "$0")/.."
LIB=$SKY130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
CF=$(tr '\n' ' ' < lab8/core_files.txt)
sed -e "s|@CORE_FILES@|$CF|" -e "s|@LIB@|$LIB|g" lab8/synth_core.ys.in > /tmp/synth_$USER.ys
tmux new-session -d -s lab8synth "nice -n 10 bash -c 'source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh; cd $(pwd)/microwatt_src; ol yosys -m ghdl -s /tmp/synth_$USER.ys' > $(pwd)/synth_core_tmux.log 2>&1"
echo "Launched in background. Watch progress:  tail -f synth_core_tmux.log"
echo "(It is safe to log out; the run continues.)"
