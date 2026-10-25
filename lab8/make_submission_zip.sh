#!/bin/bash
# Package your team's Lab 8 submission. Run from the ecen689_lab8 folder:
#   bash lab8/make_submission_zip.sh <teamnumber>
set -e
T=${1:?usage: bash lab8/make_submission_zip.sh <teamnumber>}
cd "$(dirname "$0")/.."
OUT=lab8_team${T}_submission
rm -rf $OUT ${OUT}.zip && mkdir -p $OUT/reports
cp lab8/answers.txt $OUT/
cp microwatt_src/microwatt_top.vhdl $OUT/
cp synth_core_*.log $OUT/ 2>/dev/null || cp synth_core_tmux.log $OUT/ 2>/dev/null
cp reports/*.md $OUT/reports/ 2>/dev/null
echo "$(hostname):$(pwd)" > $OUT/WORKDIR_PATH.txt; date >> $OUT/WORKDIR_PATH.txt
MISSING=0
for f in $OUT/answers.txt $OUT/microwatt_top.vhdl; do [ -f $f ] || { echo "MISSING: $f"; MISSING=1; }; done
ls $OUT/reports/*.md >/dev/null 2>&1 || { echo "MISSING: individual reports in reports/<name>.md"; MISSING=1; }
ls $OUT/synth_core*.log >/dev/null 2>&1 || { echo "MISSING: synthesis log"; MISSING=1; }
[ $MISSING -eq 1 ] && { echo "Fix the missing items above, then rerun."; exit 1; }
zip -qr ${OUT}.zip $OUT
echo "CREATED: $(pwd)/${OUT}.zip  -- download this and upload to Canvas (one per team)"
