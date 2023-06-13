# Genome-Index-splitter (GIS)

The algorithm "Genome-Index-splitter (GIS)" will split the chromosomes into multiple intervals (also called as “Chunks”) without any overlap. </br>
This is an independent scirpt. A “Chromosome Split Table” will be generated for parallel data distribution across the nodes. </br> 
Parallell data distribution based on “Chromosome Split Table” will be used to run CombineGVCF/CenomicDB and GenotypeGVCF. </br>


# Different versions
To improve the execution time of SNPs/INDELs calling, the reference genome is split into multiple ways as follows: </br> </br> 
*Version #1*: Chromosome based distribution which was part of the workflow and uses conditional operator (not an independent script).  </br> 
*Version #2:* Chunks will be distributed via job arrays and executed independently but batch by batch). </br> 
*Version #3:* Chunks will be distributed and executed as a single job via MPI, and executed concurrently across the nodes (instead of batch by batch). </br>


# Source code availability
*Version #1.* https://github.com/IBEXCluster/IBEX-SNPcaller/blob/master/downstream_analysis.sh </br>
*Version #2.* Wheat_genome_index_spliter.sh </br>
*Version #3.* MPI_genome_index_splitter.sh </br> 



