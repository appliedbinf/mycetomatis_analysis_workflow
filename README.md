# Example run instruction for using the scripts provided in this repo
This repository contains set of scripts which were utilzed for the manuscript "Genomics and metagenomics of *Madurella mycetomatis*, a causative agent of black grain mycetoma in Sudan"

## Preparation
* Download BLAST db from https://ftp.ncbi.nlm.nih.gov/blast/db/v5/
* Download minikraken from https://benlangmead.github.io/aws-indexes/k2

## Full pipeline example - Myc_16
* Concatenate lanes together (rawReads)
```
zcat Myc_16_S37_L001_R1_001.fastq.gz Myc_16_S37_L002_R1_001.fastq.gz | gzip -c > Myc_16.R1.fastq.gz
zcat Myc_16_S37_L001_R2_001.fastq.gz Myc_16_S37_L002_R2_001.fastq.gz | gzip -c > Myc_16.R2.fastq.gz
```
* Kraken v2.0.8-beta (myc_16)
Kraken database: MiniKraken2_v2_8GB: (5.5GB) 8GB Kraken 2 Database built from the Refseq bacteria, archaea, and viral libraries and the GRCh38 human genome
```
kraken2 --db ../kraken/minikraken2_v2_8GB_201904_UPDATE --threads 12 --output Myc_16.output --report Myc_16.report --paired --use-names --gzip-compressed ../rawReads/Myc_16.R1.fastq.gz ../rawReads/Myc_16.R2.fastq.gz
```
* Retreive non-human reads based on Kraken results; keeps read pair information by appending -1 or -2 to read identifier
```
gzip Myc_16.output

./getNonHuman.pl -i Myc_16.output.gz
```
* Filter out any reads with 4+ Ns in a row; also concatenates reads into single file
```
./filterNs.pl
```

* BLAST all filtered reads against custom M. mycetomatis database
```
blastn -query Myc_16-filter.fa -db ../blast/analysis2/fungalDbFiles/fungaldb -outfmt "6 qseqid sseqid length qlen slen pident qcovs evalue" -num_threads 12 -out Myc_16.fungaldb.blastOut -max_target_seqs 1
```

* Filter out M. mycetomatis reads  
```
./formatBlast2-fungaldb.pl
```

* BLAST M. mycetomatis-filtered reads against NRDB (January 2019 version; downloaded April 2019)  
```
export BLASTDB=~/mdb/blast/blastdb  

blastn -query Myc_16-notMycetomatis.fa -db ../blast/blastdb/nt_v5 -outfmt "6 qseqid sseqid length qlen slen pident qcovs evalue sscinames sblastnames sskingdoms" -num_threads 12 -out Myc_16.nrdb.blastOut -max_target_seqs 1
```
* Get GIs, pident, and qcovs  
```
./getNrdbGIs.pl
```

* Map NRDB GIs to taxid and add to file  
```
./getTaxids.pl
```

* Add mycetomatis reads back to file  
```
./addMycReads.pl
```

* Map taxids to full lineage and add to file  
```
./getRankedTaxonomy.pl
```

* Count number of other organism reads from krona outputs  
```
./countOtherReads.pl
```

* Count number of human reads identified by BLAST  
```
./countBlastHuman.pl
```
