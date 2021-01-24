#!/bin/bash

# make directories
cd OralCellDataPreparation
mkdir JPEGImages/
mkdir PredMasks/
mkdir CSVResults/
mkdir Patches/
mkdir Patches/Z_expanded/
mkdir Patches/Z_focused/
mkdir debugging/

# cd to the data directory
cd ..
# replace all spaces in filenames with '_'
for file in *.ndpi; do mv "$file" `echo $file | tr ' ' '_'` ; done

# split NDPI files
# this should generate 512 jpg images of size (6496,3360) for each slide, 
# index i01j01:i32j16 (takes about 1 h to split one whole slide)
for file in *.ndpi
do
	errname="${file}.err"
	outname="${file}.out"
	nohup ndpisplit -m100J100 -g6496x3360 -x40 "$file" >./OralCellDataPreparation/debugging/$outname 2>./OralCellDataPreparation/debugging/$errname &
done
# if the ndpisplit fails to split, use the following instead:
# for file in *.tif
# do
#     nohup tiffmakemosaic -M 100 -g 6496x3360 -j100 "$file" &
# done 


# clean margins and move all .jpg files to JPEGImages folder
python3 OralCellDataPreparation/clean_margin.py
mv *i*j*.jpg ./OralCellDataPreparation/JPEGImages/

# clean the .tif files
rm *.tif

# cd to the code directory
cd OralCellDataPreparation


# generate predicted masks
python3 predict_mask.py

# call ImageJ for blob analysis and generate .csv results for detected locations
ImageJ --headless -macro particle_analysis_fixedDirectory.ijm

# generate patches at all Z level
python3 extract_patch.py

# select the most focused patch for each location
nohup python3 select_focus.py >./nohup.out 2>./nohup.err &
# or use the following script to run in parallel
##### Parallelisation #####
# ./select_focus_parallel.sh N
# input argument N: number of processes

