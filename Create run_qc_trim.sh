#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR=~/Majoka/polony_wgs
DATA_DIR="$PROJECT_DIR/data"
OUT_DIR="$PROJECT_DIR/processed"
mkdir -p "$OUT_DIR"/{trimmed,fastqc,multiqc,spades,bam,abricate_results}

cd "$DATA_DIR"

# use samples_50.txt created earlier
SAMPLES_FILE="$DATA_DIR/samples_50.txt"
if [ ! -s "$SAMPLES_FILE" ]; then
  echo "samples_50.txt not found in $DATA_DIR"
  exit 1
fi

export THREADS=8

while read -r sample; do
  echo "=== processing $sample ==="
  R1=$(ls "${sample}"*R*1*.fastq.gz "${sample}"*_1*.fastq.gz 2>/dev/null | head -n1)
  R2=$(ls "${sample}"*R*2*.fastq.gz "${sample}"*_2*.fastq.gz 2>/dev/null | head -n1)
  if [ -z "$R1" ] || [ -z "$R2" ]; then
    echo "paired files for $sample not found; skipping"
    continue
  fi
  out_prefix="$OUT_DIR/trimmed/${sample}"
  fastp -i "$R1" -I "$R2" -o "${out_prefix}_R1.trim.fastq.gz" -O "${out_prefix}_R2.trim.fastq.gz" \
        -h "$OUT_DIR/fastqc/${sample}_fastp.html" -j "$OUT_DIR/fastqc/${sample}_fastp.json" -w $THREADS
done < "$SAMPLES_FILE"

# Optional: multiqc
cd "$OUT_DIR/fastqc"
multiqc . -o ../multiqc || true
