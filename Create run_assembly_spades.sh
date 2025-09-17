#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR=~/Majoka/polony_wgs
OUT_DIR="$PROJECT_DIR/processed"
SPADES_OUT="$OUT_DIR/spades"
mkdir -p "$SPADES_OUT"
THREADS=12

cd "$PROJECT_DIR/data"
SAMPLES_FILE="samples_50.txt"

while read -r sample; do
  R1="$OUT_DIR/trimmed/${sample}_R1.trim.fastq.gz"
  R2="$OUT_DIR/trimmed/${sample}_R2.trim.fastq.gz"
  if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
    echo "trimmed reads for $sample not found; skipping"
    continue
  fi
  outdir="$SPADES_OUT/${sample}"
  if [ -d "$outdir" ]; then
    echo "spades output exists for $sample, skipping"
    continue
  fi
  spades.py -1 "$R1" -2 "$R2" -o "$outdir" -t $THREADS -m 32 --careful
  # keep contigs
  cp "$outdir/contigs.fasta" "$SPADES_OUT/${sample}.contigs.fasta"
done < "$SAMPLES_FILE"
