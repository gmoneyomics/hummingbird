#!/bin/bash

fastq='/kyber/Data/temp/gmoney/hummingbird/data/fastq/mg96.98.clean.fq.gz'
ref='/dilithium/Data/assemble/acolubris/rubyref.mmi'
mmapbatch='20M'
outdir='/kyber/Data/temp/gmoney/hummingbird/alignment'
fast5='/kyber/Data/temp/gmoney/hummingbird/data/fast5/'
sum='/kyber/Data/temp/gmoney/hummingbird/data/summary/*tsv.gz'
bam='/kyber/Data/temp/gmoney/hummingbird/alignment/ruby.align.bam'
fasta='/kyber/Data/temp/gmoney/hummingbird/alignment/ruby.contigs.fasta'

# minimap alignment 

##reset K to lower to prevent memory overuse
if [ "$1" == "aln" ]; then
    minimap2 -t 10 -ax map-ont -K ${mmapbatch} $ref $fastq |
    samtools view -b - | samtools sort -o ${outdir}/ruby.align.bam
    samtools index ${outdir}/ruby.align.bam
fi


# cat the summary files from all 6 nanopore runs
# remove headers and only include one header 
if [ "$1" == "cat" ]; then
    mkdir $outdir/sum
    echo 'formatting summary file'

    for samp in  $sum
     do
       printf '\n'
       echo $(basename $samp)
       file=$(basename $samp)
       echo 'making dir to store analysis'
       mkdir $outdir/sum
       cp $samp $outdir/sum/
       newdir=$outdir/sum/
       echo 'unzipping $samp file'
       gunzip $newdir/$file
       #this removes all header lines from all the summary file
       echo 'removing headerlines'
       new=${file::-3}
       echo $new
       sed -i '/^filename\tread_id/d' $newdir/$new
     done
         #this combines the header file(in this dir) with the summary  file
     cat head.txt $newdir/*  > \
           $newdir/summaryCAT.txt

     echo 'removing old (unformatted) summary file from analysis directory'
     rm $newdir/*.tsv

     echo """summary file ending with "CAT.txt" is now formatted"""
fi

# need to untar all fast5 and move into respective directories

#Isac's faster code for cat step #
#sumdir=/kyber/Data/temp/gmoney/hummingbird/data/summary
#out=/kyber/Data/temp/gmoney/hummingbird/alignment/sum/summaryCAT.txt

#if [ "$1" == "cat" ]; then
#  sums=$(find $sumdir -name "*tsv.gz")
#  gunzip -c $sums |\
#  awk 'NR==1||$1!="filename"{ print }' > $out
#fi


if [ "$1" == "index" ]; then
   # source activate polish
    nanopolish index -d $fast5/  -s $outdir/sum/summaryCAT.txt  $fastq
fi



if [ "$1" == "consensus" ]; then
    source activate polish
    python /home/gmoney/.conda/envs/polish/bin/nanopolish_makerange.py $fasta | parallel --results nanopolish.results -P 8 \
           nanopolish variants --consensus -o polished.{1}.fa -w {1} -r $fastq -b $bam -g $fasta -t 4 --min-candidate-frequency 0.1
fi

     
   
