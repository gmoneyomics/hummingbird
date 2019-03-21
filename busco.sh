#!/bin/bash
seq='/dilithium/Data/assemble/acolubris/ruby.contigs.fasta'

if [ "$1" == "install" ]; then
  #conda create --name busco
  source activate busco
  git clone git@gitlab.com:ezlab/busco.git
  cd ~/.conda/envs/busco/busco
  python setup.py install --user
  cd ~/.conda/envs/busco/busco/config
  cp config.ini.default config.ini
  export BUSCO_CONFIG_FILE="~/.conda/envs/busco/busco/config/config.ini"
  # dependencies 
  cd ../..
  wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.8.1+-src.tar.gz
  tar -xzf ncbi-blast-2.8.1+-src.tar.gz
  # scp hmmer-3.2.2.tar.gz to busco dir
  tar -xzf hmmer-3.2.1.tar.gz
  # scp Augustus to busco dir
  tar -xzf augustus.current.tar.gz
  # add file paths to config.ini
  source deactivate busco
fi

if [ "$1" == "busco" ]; then
  source activate busco
 # python /home/rworkman/repos/busco2/busco/BUSCO.py -i $seq -o ruby.busco2 -l /home/gmoney/.conda/envs/busco/busco/eukaryota_odb9 -m geno
  python /home/rworkman/repos/busco2/busco/BUSCO.py -i $seq -o ruby.busco_ave -l /home/gmoney/.conda/envs/busco/busco/aves_odb9 -m geno
  python /home/rworkman/repos/busco2/busco/BUSCO.py -i $seq -o ruby.busco_met -l /home/gmoney/.conda/envs/busco/busco/metazoa_odb9 -m geno

fi
