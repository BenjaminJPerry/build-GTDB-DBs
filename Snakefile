# Copyright (c) 2022 Benjamin J Perry
# Version: 1.0
# Maintainer: Benjamin J Perry
# Email: ben.perry@agresearch.co.nz

configfile: 'config/config.yaml'

import os

onstart:
    print(f'Working directory: {os.getcwd()}')

    print('TOOLS: ')
    os.system("echo '  bash: $(which bash)'")
    os.system("echo '  PYTHON: $(which python)'")
    os.system("echo '  CONDA: $(which conda)'")
    os.system("echo '  SNAKEMAKE: $(which snakemake)'")
    print(f"Env TMPDIR = {os.environ.get('TMPDIR', '<n/a>')}")

    os.system("echo '  PYTHON VERSION: $(python --version)'")
    os.system("echo '  CONDA VERSION: $(conda --version)'")



rule targets:
    input:
        'Struo2/Snakefile',
        'GTDB/gtdb_genomes_reps_latest.tar.gz',
        'GTDB/bac120_taxonomy_latest.tsv',
        'GTDB/ar53_taxonomy_latest.tsv',
        'GTDB/taxid.map'
        # GTDB-Kraken2,
        # GTDB-Centrifuge,
        # GTDB-KMCP,
        # GTDB-Ganon,
        # GTDB-blastn,
        # GTDB-blastp,
        # GTDB-humann-protein,
        # GTDB-humann-nucleotide



### Prepare ###
rule getStruo2:
    output:
        directory('Struo2'),
        'Struo2/Snakefile'
    conda:
        'env/struo2.yaml'
    threads:8
    message:
        'Cloning Struo2 repository: https://github.com/leylabmpi/Struo2.git...'
    shell:
        '''
        git clone https://github.com/leylabmpi/Struo2.git;
        cd Struo2;
        git submodule update --remote --init --recursive;
        '''



rule getGTDBGenomes:
    output:
        gtdb-tar = 'GTDB/gtdb_genomes_reps_latest.tar.gz'
    conda:
        'env/struo2.yaml'
    message:
        'Downloading GTDB release: '
    params:
        gtdb-genomes = config['gtdb-genomes']
    shell:
        '''
        wget -O {output.gtdb-tar} {params.gtdb-genomes};
        '''



rule getGTDBBacTax:
    output:
        bac-tax = 'GTDB/bac120_taxonomy_latest.tsv'
    conda:
        'env/struo2.yaml'
    message:
        'Downloading GTDB bacterial taxonomy...'
    threads: 2
    params:
        gtdb-bac-tax = config['gtdb-bac-tax']
    shell:
        '''
        wget -O GTDB/bac120_taxonomy_latest.tsv.gz {params.gtdb-bac-tax};
        gunzip -c GTDB/bac120_taxonomy_latest.tsv.gz > {output.bac-tax};
        '''



rule getGTDBArcTax:
    output:
        arc-tax = 'GTDB/ar53_taxonomy_latest.tsv'
    conda:
        'env/struo2.yaml'
    message:
        'Downloading GTDB archaeal taxonomy...'
    threads: 2
    params:
        gtdb-bac-tax = config['gtdb-arc-tax']
    shell:
        '''
        wget -O GTDB/ar53_taxonomy_latest.tsv.gz {params.gtdb-arc-tax};
        gunzip -c GTDB/ar53_taxonomy_latest.tsv.gz > {output.arc-tax};
        '''



rule taxdumpGTDB:
    input:
        bac = rules.getGTDBBacTax.output.bac-tax,
        arc = rules.getGTDBArcTax.output.arc-tax
    output:
        'GTDB/taxid.map',
        'GTDB/nodes.dmp',
        'GTDB/names.dmp',
        'GTDB/merged.dmp',
        'GTDB/delnodes.dmp',
    conda:
        'env/taxkit.yaml'
    message:
        'Creating taxdump files...'
    threads: 2
    shell:
        '''
        taxonkit create-taxdump {input.bac} {input.arc} --gtdb --out-dir GTDB/ --force;
        '''



rule prepGTDBGenomes:



# rule prepGTDBTaxonomy:



# rule buildKraken2:

# rule buildBraken:

# rule buildKCMP:

# rule buildCentrifuge:

# rule buildGanon:

# ### Humann3 DBs ###

# rule buildHumann3:




