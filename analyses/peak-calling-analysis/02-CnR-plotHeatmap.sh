#!/bin/bash

set -e
set -o pipefail

########################################################################
# Load modules
module load deeptools/3.5.4

########################################################################
# Set up running directory
cd "$(dirname "${BASH_SOURCE[0]}")" 

########################################################################
# Set variables
cellLine=("cellLine1" "cellLine2")

PVALS=(0.0001 0.00001)
colors=("PiYG" "BrBG" "Spectral" "RdGy_r" "RdYlBu" "PuOr" "RdYlGn_r")
YAXIS="CPM"
ZMIN=0
ZMAX="auto"

RESULTS="results"

########################################################################
# Directories and paths to file Inputs/Outputs
mkdir -p ./plots
mkdir -p ./plots/01-plotHeatmap
mkdir -p ./${RESULTS}/04-plotHeatmap

########################################################################
# Run plotHeatmap function
# https://deeptools.readthedocs.io/en/develop/content/tools/plotHeatmap.html
# This tool creates a heatmap for scores associated with genomic regions. 
# The program requires a matrix file generated by the tool computeMatrix.

for i in "${!cellLine[@]}"; do
     
    for p in "${PVALS[@]}"; do
    
         # Create dir 
         mkdir -p ./plots/01-plotHeatmap/${cellLine[i]} # to save plots
         mkdir -p ./${RESULTS}/04-plotHeatmap/${cellLine[i]} # to save results
         
         # Run `plotHeatmap` function on all peaks together
         bsub -P baker -J plotHeatmap-macs2-pvalfilt-${cellLine[i]}-${p} -B -N -n 4 -R "rusage[mem=8GB] span[hosts=1]" -M 4GB -q standard \
             plotHeatmap -m ./${RESULTS}/03-computeMatrix/${cellLine[i]}/macs2-peaks-merged-pvalfilt-${p}-10kb.matrix.gz \
                         -out ./plots/01-plotHeatmap/${cellLine[i]}/macs2-peaks-merged-pvalfilt-${p}-10kb-heatmap.pdf \
                         --colorMap ${colors[@]} \
                         --plotTitle "${cellLine[i]} MACS2 (p < ${p}) Narrow Peaks" \
                         -z Peaks \
                         -y "$YAXIS" -x "Distance (Peak Center)" \
                         --heatmapHeight 11 \
                         --heatmapWidth 5 \
                         --refPointLabel "Peak Center" \
                         --dpi 300 \
                         --zMax $ZMAX \
                         --zMin $ZMIN \
                         --outFileSortedRegions ./${RESULTS}/04-plotHeatmap/${cellLine[i]}/macs2-peaks-merged-pvalfilt-${p}-10kb-heatmap-sorted.bed \
                         --outFileNameMatrix ./${RESULTS}/04-plotHeatmap/${cellLine[i]}/macs2-peaks-merged-pvalfilt-${p}-10kb-heatmap-matrix.tab;
                         
        
       # Run `plotHeatmap` function on promoter, "typical" enhancers, super enhancers, and other peaks
         bsub -P baker -J plotHeatmap-macs2-pvalfilt-${cellLine[i]}-${p}-SPLIT -B -N -n 4 -R "rusage[mem=16GB] span[hosts=1]" -M 16GB -q standard \
             plotHeatmap -m ./${RESULTS}/03-computeMatrix/${cellLine[i]}/macs2-peaks-grouped-merged-pvalfilt-${p}-10kb.matrix.gz \
                         -out ./plots/01-plotHeatmap/${cellLine[i]}/macs2-peaks-grouped-merged-pvalfilt-${p}-10kb-heatmap.pdf \
                         --colorMap ${colors[@]} \
                         --plotTitle "${cellLine[i]} MACS2 (p < ${p}) Narrow Peaks grouped" \
                         -z Promoter "SE" "TE" Other -y "$YAXIS" -x "Distance (Peak Center)" \
                         --heatmapHeight 14 \
                         --heatmapWidth 5 \
                         --refPointLabel "Peak Center" \
                         --dpi 300 \
                         --zMax $ZMAX \
                         --zMin $ZMIN \
                         --outFileSortedRegions ./${RESULTS}/04-plotHeatmap/${cellLine[i]}/macs2-peaks-grouped-merged-pvalfilt-${p}-10kb-heatmap-sorted.bed \
                         --outFileNameMatrix ./${RESULTS}/04-plotHeatmap/${cellLine[i]}/macs2-peaks-grouped-merged-pvalfilt-${p}-10kb-heatmap-matrix.tab;                  
    done
done




