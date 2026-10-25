#!/bin/bash
#SBATCH --job-name=lab8_synth
#SBATCH --partition=adademic
#SBATCH --qos=olympus-academic
#SBATCH --cpus-per-task=6
#SBATCH --mem=64G
#SBATCH --time=04:00:00
#SBATCH --output=synth_core_%j.log
source /mnt/nfs-scratch/ecen-689-nowka/kit/env.sh
cd "$SLURM_SUBMIT_DIR/microwatt_src"
LIB=$SKY130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
CF=$(tr '\n' ' ' < ../lab8/core_files.txt)
sed -e "s|@CORE_FILES@|$CF|" -e "s|@LIB@|$LIB|g" ../lab8/synth_core.ys.in > /tmp/synth_$USER.ys
ol yosys -m ghdl -s /tmp/synth_$USER.ys
