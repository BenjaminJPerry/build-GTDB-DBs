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
        "Struo2/Snakefile",
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
        directory("Struo2"),
        "Struo2/Snakefile"
    conda:
        "env/struo2.yaml"
    threads:8
    message:
        "Cloning Struo2 repository: https://github.com/leylabmpi/Struo2.git..."
    shell:
        """
        git clone https://github.com/leylabmpi/Struo2.git;
        cd Struo2;
        git submodule update --remote --init --recursive;
        """

# rule getGTDBGenomes:

# rule getGTDBArchTax:

# rule getGTDBBactTax:

# rule prepGTDBGenomes:

# rule prepGTDBTaxonomy:

# rule taxdumpGTDB:



# rule buildKraken2:

# rule buildBraken:

# rule buildKCMP:

# rule buildCentrifuge:

# rule buildGanon:

# ### Humann3 DBs ###

# rule buildHumann3:




