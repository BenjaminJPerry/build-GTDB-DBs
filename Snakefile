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
        'Struo2-AgR-Tweaks/Snakefile',
        'GTDB/gtdb_genomes_reps_latest.tar.gz',
        'GTDB/bac120.metadata.tsv',
        'GTDB/arc53.metadata.tsv',
        'GTDB/bac120_taxonomy_latest.tsv',
        'GTDB/ar53_taxonomy_latest.tsv',
        'taxdump/taxid.map',
        'Struo2-AgR-Tweaks/data/UniRef90/uniref90',
        'Struo2-AgR-Tweaks/data/UniRef90/uniref50-90.pkl',
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
        directory('Struo2-AgR-Tweaks'),
        'Struo2-AgR-Tweaks/Snakefile'
    conda:
        'struo2'
    threads: 2
    message: 'Cloning Struo2-AgR-Tweaks repository: https://github.com/BenjaminJPerry/Struo2-AgR-Tweaks.git...'
    shell:
        '''
        git clone https://github.com/BenjaminJPerry/Struo2-AgR-Tweaks.git;
        cd Struo2-AgR-Tweaks;
        git submodule update --remote --init --recursive;
        '''



rule getUniRef90Struo2:
    output:
        uniref90tar='Struo2-AgR-Tweaks/data/UniRef90_mmseqs.tar.gz'
    conda:
        'struo2'
    threads: 2
    resources:
        time = 2880 # minutes
    message: 'Downloading Struo2 Uniref90 DB...'
    params:
        uniref90=config['struo2-uniref90']
    shell:
        '''
        wget -O {output.uniref90tar} {params.uniref90};
        '''    



rule untarUniref90:
    output:
        uniref90='Struo2-AgR-Tweaks/data/UniRef90/uniref90',
    input:
        rules.getUniRef90Struo2.output.uniref90tar
    conda:
        'struo2'
    threads: 2
    message: 'Unpacking Struo2-AgR-Tweaks/data/UniRef90_mmseqs.tar.gz...'
    shell:
        '''
        tar -pzxvf {input} --directory Struo2-AgR-Tweaks/data
        '''



rule getUnirefMapping:
    output:
        unirefMap='Struo2-AgR-Tweaks/data/UniRef90/uniref50-90.pkl'
    conda:
        'struo2'
    threads: 2
    message: 'Downloading Struo2 UniRef mapping pkl...'
    params:
        unirefPkl=config['struo2-uniref-mapping']
    shell:
        '''
        wget -O {output.unirefMap} {params.unirefPkl}
        '''



rule getGTDBBacMetadata:
    output:
        bac120Metadata='GTDB/bac120.metadata.tsv'
    conda:
        'struo2'
    message: 'Downloading bac120_metadata_r207.tar.gz...'
    threads: 2
    params:
        bacMeta=config['gtdb-bac-metadata']
    shell:
        '''
        wget -O GTDB/bac120_metadata_r207.tar.gz {params.bacMeta};
        gunzip -c GTDB/bac120_metadata_r207.tar.gz > {output.bac120Metadata}
        '''



rule getGTDBArcMetadata:
    output:
        arc53Metadata='GTDB/arc53.metadata.tsv'
    conda:
        'struo2'
    message: 'Downloading ar53_metadata_r207.tar.gz...'
    threads:2
    params:
        arcMeta=config['gtdb-arc-metadata']
    shell:
        '''
        wget -O GTDB/ar53_metadata_r207.tar.gz {params.arcMeta};
        gunzip -c GTDB/ar53_metadata_r207.tar.gz > {output.arc53Metadata}
        '''



rule getGTDBBacTax:
    output:
        bacTax='GTDB/bac120_taxonomy_latest.tsv'
    conda:
        'struo2'
    message: 'Downloading GTDB bacterial taxonomy...'
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
    message: 'Downloading GTDB archaeal taxonomy...'
    threads: 2
    params:
        gtdbArcTax = config['gtdb-arc-tax']
    shell:
        '''
        wget -O GTDB/ar53_taxonomy_latest.tsv.gz {params.gtdbArcTax};
        gunzip -c GTDB/ar53_taxonomy_latest.tsv.gz > {output.arcTax};
        '''



rule getGTDBGenomes:
    output:
        gtdbTar='GTDB/gtdb_genomes_reps_latest.tar.gz'
    conda:
        'struo2'
    message: 'Downloading GTDB release: '
    threads: 2
    resources:
        time = lambda wildcards, attempt: attempt * 4320 # minutes
    params:
        gtdbGenomes=config['gtdb-genomes']
    shell:
        '''
        wget -O {output.gtdbTar} {params.gtdbGenomes};
        '''



rule prepGTDBGenomes:
    input:
        rules.getGTDBGenomes.output.gtdbTar
    output:
        directory('GTDB/genomes')
    conda:
        'struo2'
    message: 'Preparing GTDB genomes...'
    threads: 2
    resources:
        time = lambda wildcards, attempt: attempt * 24 * 60 # hours * minutes
    shell:
        '''
        mkdir -p GTDB/gtdb_genomes_reps_latest;
        mkdir -p GTDB/genomes;
        find GTDB/gtdb_genomes_reps_latest -name "*.fna.gz" -exec mv -t GTDB/genomes/ {} +;
        '''



rule prepGTDBTaxonomy:
    output:
        taxonomy="GTDB/gtdbTaxonomy.tsv"
    input:
        bac=rules.getGTDBBacTax.output.bacTax,
        arc=rules.getGTDBArcTax.output.arcTax
    conda:
        'struo2'
    message: 'Merging taxonomy files...'
    threads:2
    shell:
        '''
        cat {input.bac} {input.arc} > {output.taxonomy}
        '''



rule prepKraken2Build:
    output:
        directory('GTDB/kraken_genomes')
    input:
        genomes=rules.prepGTDBGenomes.output,
        taxonomy=rules.prepGTDBTaxonomy.output.taxonomy,
        tax_from_gtdb='scripts/tax_from_gtdb.py'
    conda:
        'struo2'
    message: 'Preparing genomes for kraken2 build...'
    threads: 2
    shell:
        '''
        python {input.tax_from_gtdb} --gtdb {input.taxonomy} --assemblies {input.genomes} --nodes nodes.dmp --names names.dmp --kraken_dir GTDB/kraken_genomes
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
    message: 'Creating taxdump files...'
    threads: 2
    shell:
        '''
        taxonkit create-taxdump {input.bac} {input.arc} --gtdb --out-dir taxdump --force;
        '''

# rule buildKCMP:

# rule buildCentrifuge:

# rule buildGanon:
