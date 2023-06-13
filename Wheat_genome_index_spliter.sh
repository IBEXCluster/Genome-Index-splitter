#!/bin/bash
## Ver 3.0 dated 18 Oct, 2021
function main()
{
  read -p " How many CPUs (cores) you are planning to use:  " MaxRanks
  read -p " Please enter absolute path of the reference genome with name (e.g. /ibex/scratch/projects/c2023/einkorn/Resequencing/Ref_final/TA299_v1.0.fasta) : " REF
  read -p " Please enter absolute path of your gVCF files directory: " INPDIR 
#  read -p " Please enter absolute path for your resutls directory: " OUTDIR 
  Validate;
  FindMaxSizeofChr ;
  FindOptimalChunk ;
  DistributeParallel ;
  RequiredCPU;
  InputPrepare ;
}

function Validate()
{
  ## Check the number of CPUs are integer 
  if ! [[ "$MaxRanks" =~ ^[0-9]+$ ]]; then
   echo "Please give number of CPUs (in number ONLY)"
   exit;    
  fi

  ## Check the Reference Genome Index
  if [ ! -f $REF.fai ]; then
    echo "Reference Genome Index file not found! Please create Index file ;-)"
    exit 1;
  fi
}

function FindMaxSizeofChr()
{
  MaxSize=0 ;
  while IFS=$'\t' read -r -a myREF
  do
     ChrName=${myREF[0]};
     ChrLen=${myREF[1]};
     if [ $MaxSize -lt $ChrLen ]; then
       MaxSize=$ChrLen
     fi
  done < $REF.fai 
   echo " "
   echo "*************************************************************"
  echo "Max size of Chromosome in the given reference is:" $MaxSize
  #Find the total numbers of Chr
  TotalChr=`cat $REF.fai | wc -l `
  echo "Total no. of Chromosomes in the given reference is:"  $TotalChr 
  if [[ $MaxRanks -lt $TotalChr ]]; then
   echo "This algorithm required at least $TotalChr CPUs. However, the provided CPUs=$MaxRanks is insufficient for performance improvement"
    exit 1;
  fi
}


function FindOptimalChunk()
{
  #Find the best possible Chunk size 
  Divide=1;
  AssinedJobs=1;
  while [ ${MaxRanks} -gt $AssinedJobs ];
  do
     Divide=$(( $Divide + 1 ));
     AssinedJobs=$(( $Divide * $TotalChr )) ;
  done
  Divide=$(( Divide - 1 ));
  Chunk=$(( $MaxSize / $Divide ));
  #echo "total Chr = $TotalChr, Max Chr length = $MaxSize, Chunk number = $Divide, Chunk size = $Chunk "
}



function DistributeParallel()
{ 
  #Prepare Chromosome Chunk intervals in a file "submitted_chunks_data.txt"
  rm -Rf submitted_chunks_data.txt split.txt distribution.txt;
  while IFS=$'\t' read -r -a myREF
  do
    ChrName=${myREF[0]};
    ChrLen=${myREF[1]};
    Part=$(( $ChrLen / $Chunk )) ;
    tmp=$(( $Part * $Chunk )) ;
    if [ $ChrLen -gt $tmp ]; then
      Part=$(( $Part + 1 ));
      ## Equal partitiaons 
      echo "$ChrName split into $Part parts" >> submitted_chunks_data.txt
    else
      ## Last part of the partition
      echo "$ChrName split into $Part parts" >> submitted_chunks_data.txt
    fi
   done < $REF.fai

  #Prepare a Chromosome Interval Distributoion across all the reference genome 
   while IFS=$'\t' read -r -a myREF
   do
     size=1;
     DefSize=$Chunk;
     ChunkSize=$DefSize;
     ChrName=${myREF[0]};
     ChrLen=${myREF[1]};
  
     ## PREPARE CHUNKS [Begin:End] Intervals for EACH CHROMOSOME 
      for ((Start=1; Start<$ChrLen; Start+=$DefSize))
      do
         End=$(( $size*$ChunkSize ))
         if [ $End -lt $ChrLen ]
         then
           echo "$ChrName   $size   $Start  $End"  >> split.txt
           size=$(( $size + 1 ));
         else   ### Last chunk 
           Start=$(( $End - $ChunkSize +1 ));
           End=$ChrLen;
           echo "$ChrName  $size  $Start  $End"   >> split.txt
         fi ## END OF ALL CHUNKS within the specific CHROMOSOME 
          #echo "Preparing for the next Chunk:" $ChrName.chunk_$size 
       done ## END OF CHROMOSOME (Chr by Chr) 
       echo "$ChrName    $size" >> distribution.txt
    done < $REF.fai
    ## END OF ALL CHROMOSOMEs
}

function RequiredCPU()
{ 
  echo " ***************************************************"
  echo " Useful details: "
  echo " Chromosome based number of partitions available in: submitted_chunks_data.txt" 
  echo " Chromosome based chunk intervals available in: split.txt" 
  echo " Reference Genome distribution is available in: distribution.txt " 
  TotalLines=`cat split.txt | wc -l` ;
  sed -i "3s/.*/#SBATCH --array=1-$TotalLines/" WheatGenome_SNPCalling.batch ;
# sed -i "17s/.*/export REF=$REF/" WheatGenome_SNPCalling.batch ;
#  sed -i "18s/.*/export OUTPUT=$OUTDIR/" WheatGenome_SNPCalling.batch ;
  echo "    Please adjust --time & --mem in the 'WheatGenome_SNPCalling.batch' and submit your job"
  echo " ***************************************************"
}

function InputPrepare()
{
 ## Add all the *.g.vcf files for CombineGVCF
 set INPUT_TMP
 for i in `ls -l ${INPDIR}/*.g.vcf | awk '{print $9}'`
 do
   INPUT_TMP+="$i -V ";
 done
 INPUT=${INPUT_TMP::-4}
  echo $INPUT > Phase3.input.list
}
main "$@"
