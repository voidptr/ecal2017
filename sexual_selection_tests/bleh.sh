#!/bin/bash

me=`basename $0`

if [ $# -lt 2 ]
then
    echo "usage ${me} <description> <prefix>"
    echo "e.g. % ${me} \"118\" 118"
    exit
fi

description=$1
prefix=$2

echo "Description: " $1 ${1}
echo "Prefix: " $2 ${2}

module load matplotlib

each_dir() {

    pattern=$1
    funct=$2

    for k in *_${prefix}???;
    do
        if [[ -e ${k}/${pattern} ]]
        then
            echo $k;
            cd $k/${pattern};
            pwd;
              
            eval ${funct}
            
            cd -;
        fi ;
    done
}

each_root_dir() {

    pattern=$1
    funct=$2

    echo "1"

    roots=( Ctrl ScenA ScenB ScenC ScenD ScenE )
    for root in ${roots[@]}
    do
        echo $root

        for k in ${root}*_${prefix}???;
        do
            echo $k
            path=${k}/${pattern}
            if [[ -f $path ]]
            then
                echo $k;
                cd $k/${pattern};
                pwd;
              
                eval ${funct}
            
                cd -;
            fi ;
        done
    done
}

extract_forcedmatings() {

    rm *recombinant_viability.csv    
    
    roots=( Ctrl ScenA ScenB ScenC ScenD_Drift ScenE )
    for root in ${roots[@]}
    do
        dobit=true

        for k in ${root}*_${prefix}???;
        do
            path=${k}/data__${root}_analyze
            file=${path}/detail_avg__baselined.dat
            if [ -e $file ]
            then
                cd $path;
                pwd;

                if [ $dobit == true ]
                then
                    part1=`python ~/research_scripts/common/extract_single_column_to_csv.py 1 detail_avg__baselined.dat`
                    header="#"${part1}
                    echo $header > ../../${root}_recombinant_viability.csv
                    dobit=false
                fi
                
                python ~/research_scripts/common/extract_single_column_to_csv.py 2 detail_avg__baselined.dat >> ../../${root}_recombinant_viability.csv
            
                cd -;
            fi ;
        done
    done

    #cat detail_avg.dat | tail -n +26 >> detail-total.spop;
   
    
}

plot_forcedmatings() {

        python ~/research_scripts/graph_generation/bar_chart_from_csv.py \
        -x Treatment -y "Viability" -t "Forced Matings (unfiltered) - Viability - ${description}" --pair --groups=5 \
        --xticks="Drift,A,B,C,E" --legend="ViabilityAA,ViabilityBB,ViabilityAB" \
        --columns="11,17,5" --error \
        ${prefix}_forcedmatingviability_unfiltered.png \
        ScenD_Drift_recombinant_viability.csv \
        ScenA_recombinant_viability.csv \
        ScenB_recombinant_viability.csv \
        ScenC_recombinant_viability.csv \
        ScenE_recombinant_viability.csv

        python ~/research_scripts/graph_generation/bar_chart_from_csv.py \
        -x Treatment -y "Viability" -t "Forced Matings (viable parents) - Viability - ${description}" --pair --groups=5 \
        --xticks="Drift,A,B,C,E" --legend="ViabilityAA,ViabilityBB,ViabilityAB" \
        --columns="14,20,8" --error \
        ${prefix}_forcedmatingviability_filtered.png \
        ScenD_Drift_recombinant_viability.csv \
        ScenA_recombinant_viability.csv \
        ScenB_recombinant_viability.csv \
        ScenC_recombinant_viability.csv \
        ScenE_recombinant_viability.csv

        roots=( ScenA ScenB ScenC ScenD_Drift ScenE )
        for root in ${roots[@]}
        do
            echo $root
            python ~/research_scripts/graph_generation/scatterplot_from_csv.py \
            -x "AB Recombinant Viability" -y "AA and BB Recombinant Viability" \
            -t "${root} - Unfiltered AA/BB vs AB Recombinant Viability - ${description}" \
            -c "5,11,17" \
            ${prefix}_${root}_AABBvsAB_unfiltered_viability.png \
            ${root}_recombinant_viability.csv \
            ${root}_recombinant_viability.csv \
            ${root}_recombinant_viability.csv
            echo " "
            python ~/research_scripts/graph_generation/scatterplot_from_csv.py \
            -x "AB Recombinant Viability" -y "AA and BB Recombinant Viability" \
            -t "${root} - Filtered AA/BB vs AB Recombinant Viability - ${description}" \
            -c "8, 14, 12" \
            ${prefix}_${root}_AABBvsAB_filtered_viability.png \
            ${root}_recombinant_viability.csv \
            ${root}_recombinant_viability.csv \
            ${root}_recombinant_viability.csv

        done
}

#extract_forcedmatings
plot_forcedmatings

