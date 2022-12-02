# Copyright (c) 2022 Benjamin J Perry
# Version: 1.0
# Maintainer: Benjamin J Perry
# Email: ben.perry@agresearch.co.nz

configfile: "config/config.yaml"

import os

onstart:
    print(f"Working directory: {os.getcwd()}")

    print("TOOLS: ")
    os.system('echo "  bash: $(which bash)"')
    os.system('echo "  PYTHON: $(which python)"')
    os.system('echo "  CONDA: $(which conda)"')
    os.system('echo "  SNAKEMAKE: $(which snakemake)"')
    print(f"Env TMPDIR = {os.environ.get('TMPDIR', '<n/a>')}")

    os.system('echo "  PYTHON VERSION: $(python --version)"')
    os.system('echo "  CONDA VERSION: $(conda --version)"')



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
        'struo2'
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
        gtdbTar='GTDB/gtdb_genomes_reps_latest.tar.gz'
    conda:
        'struo2'
    message:
        'Downloading GTDB release: '
    params:
        gtdbGenomes=config['gtdb-genomes']
    shell:
        '''
        wget -O {output.gtdbTar} {params.gtdbGenomes};
        '''



rule getGTDBBacTax:
    output:
        bacTax='GTDB/bac120_taxonomy_latest.tsv'
    conda:
        'struo2'
    message:
        'Downloading GTDB bacterial taxonomy...'
    threads: 2
    params:
        gtdbBacTax=config['gtdb-bac-tax']
    shell:
        '''
        wget -O GTDB/bac120_taxonomy_latest.tsv.gz {params.gtdbBacTax};
        gunzip -c GTDB/bac120_taxonomy_latest.tsv.gz > {output.bacTax};
        '''



rule getGTDBArcTax:
    output:
        arcTax='GTDB/ar53_taxonomy_latest.tsv'
    conda:
        'struo2'
    message:
        'Downloading GTDB archaeal taxonomy...'
    threads: 2
    params:
        gtdbArcTax = config['gtdb-arc-tax']
    shell:
        '''
        wget -O GTDB/ar53_taxonomy_latest.tsv.gz {params.gtdbArcTax};
        gunzip -c GTDB/ar53_taxonomy_latest.tsv.gz > {output.arcTax};
        '''



rule taxdumpGTDB:
    input:
        bac = rules.getGTDBBacTax.output.bacTax,
        arc = rules.getGTDBArcTax.output.arcTax
    output:
        'taxdump/taxid.map',
        'taxdump/nodes.dmp',
        'taxdump/names.dmp',
        'taxdump/merged.dmp',
        'taxdump/delnodes.dmp',
    conda:
        'taxonkit'
    message:
        'Creating taxdump files...'
    threads: 2
    shell:
        '''
        taxonkit create-taxdump {input.bac} {input.arc} --gtdb --out-dir taxdump --force;
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




