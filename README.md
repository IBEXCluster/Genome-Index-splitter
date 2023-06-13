# Downstream-analysis
Parallell data distribution for downstream analysis (e.g. SNPs calling) 

# Different versions
To improve the execution time of SNPs/INDELs calling, the reference genome is split into multiple ways as follows: </br> </br> 
*Version #1*: Chromosome based distribution </br> 
*Version #2:* Split the chromosome into multiple intervals without overlapping and called as “Chunks” </br>
*Version #3:* Chromosome based split (in Version #2) will be executed as a single job via MPI </br>
            (for parallel data distribution across the nodes referred as “Chromosome Split Table”) </br> 

# Source code availability
*Version #1.* Fonio_SNPs_Calling_Downstream.sh </br>
*Version #2.* Wheat_SNPs_Calling_chunking.sh </br>
*Version #3.* Rice_Calling_Phase3.prerequisite.optimized.sh </br> 



