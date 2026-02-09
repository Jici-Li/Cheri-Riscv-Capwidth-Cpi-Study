set -euo pipefail

GEM5=~/tools/gem5/build/ARM/gem5.opt
SE=~/tools/gem5/configs/deprecated/example/se.py

TRACE=trace_small.txt
CMD=./bench_linux

WORKS=(8 16 24 32 48 64 96 128 192 256)
WIDTHS=(8 16)

L1D_SIZE="32KiB"
FA_ASSOC=512
ASSOCS=("$FA_ASSOC" 4)

CPU_TYPE="TimingSimpleCPU" 

OUTCSV=results.csv
echo "tag,assoc,work_kb,width,miss_rate,numCycles,cpi" > "$OUTCSV"

for k in "${WORKS[@]}"; do
  for w in "${WIDTHS[@]}"; do
    for a in "${ASSOCS[@]}"; do
      if [ "$a" = "$FA_ASSOC" ]; then tag="FA"; else tag="A${a}"; fi

      out="m5out_${tag}_k${k}_w${w}"

      rm -rf "$out"

      echo "Run: work=${k}KB width=${w}B assoc=${a} -> ${out}"

      "$GEM5" \
        --outdir="$out" \
        "$SE" \
        --cpu-type="$CPU_TYPE" \
        --cmd="$CMD" \
        --options="$TRACE $k $w 1" \
        --caches --l1d_size="$L1D_SIZE" --l1d_assoc="$a"

      stats="$out/stats.txt"

cycles=$(awk '$1=="system.cpu.numCycles"{print $2; exit}' "$stats")
insts=$(awk '$1=="system.cpu.committedInsts"{print $2; exit}' "$stats")
cpi=$(awk '$1=="system.cpu.cpi"{print $2; exit}' "$stats")
mr=$(awk '$1=="system.cpu.dcache.overallMissRate::total"{print $2; exit}' "$stats")

[ -z "$cycles" ] && cycles="NA"
[ -z "$insts" ] && insts="NA"
[ -z "$cpi" ] && cpi="NA"
[ -z "$mr" ] && mr="NA"

if [ "$cpi" = "NA" ] && [ "$cycles" != "NA" ] && [ "$insts" != "NA" ]; then
  cpi=$(awk -v c="$cycles" -v i="$insts" 'BEGIN{if(i>0) printf "%.6f", c/i; else print "NA"}')
fi

echo "${tag},${a},${k},${w},${mr},${cycles},${cpi}" | tee -a "$OUTCSV"



    done
  done
done

echo "Done. CSV: $OUTCSV"
echo "Now run: python plot.py"