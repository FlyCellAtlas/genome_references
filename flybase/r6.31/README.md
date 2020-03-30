# FlyBase r6.31 pre-mRNA

Here is a quick on how the `dmel-all-r6.31-premrna.gtf` was build. If you find a better way of solving this pre-mRNA issue (very likely there is), please don't hesitate to contribute via GitHub issues or Pull Requests.

## Recipe

1. Download annotation and genome from FlyBase

```
wget ftp://ftp.flybase.net/releases/current/dmel_r6.31/fasta/dmel-all-chromosome-r6.31.fasta.gz
wget ftp://ftp.flybase.net/releases/current/dmel_r6.31/gff/dmel-all-r6.31.gff.gz
```

2. Use GFFtools-GX to convert GFF to GTF

```
gff_to_gtf.py \
   dmel-all-r6.31.gff \
   > dmel-all-r6.31.gtf
```

3. Remove entries w/o strand information

```
sed -i '/\tgene\t/d' dmel-all-r6.31.gtf \
   | awk '{ if($6 == "." && $7 == "." && $8 == ".") {} else {print}}'
```

4. Add introns to GTF

```
Rscript genomes_references/utils/add_introns_to_gtf.R
```

5. Apply the Nuclei patch to Cell Ranger 3.1.0

**IMPORTANT**: This patch is completely coming from 10xGenomics and is associated with *Cell Ranger* version `3.1.0`. Be aware that this patch is considered experimental and didn't go through the careful testing like their official releases.

```
cp 0001-Nuclei-references.patch cellranger-3.1.0/cellranger-cs/3.1.0/
cd cellranger-3.1.0/cellranger-cs/3.1.0
patch -p1 < 0001-Nuclei-references.patch
```

6. Run Cell Ranger `mkref`

```
cellranger mkref \
   --genome=flybase_r6.31_premrna \
   --fasta=dmel-all-chromosome-r6.31.fasta \
   --genes=dmel-all-r6.31.premrna.gtf \
   --nuclei \
   --nthreads 16 \
   --memgb 200
```

7. Remove regions overlapping with other genes from Cell Ranger patched GTF

```
bedtools subtract \
   -a flybase_r6.31_premrna/genes/genes.gtf \
   -b dmel-all-r6.31.gtf \
   > tmp.gtf

cat dmel-all-r6.31.gtf \
   tmp.gtf | sed '/\ttranscript\t/d' \
   > dmel-all-r6.31_premrna_final.gtf
bedtools sort -i dmel-all-r6.31_premrna_final.gtf > dmel-all-r6.31_premrna_final.sorted.gtf
```