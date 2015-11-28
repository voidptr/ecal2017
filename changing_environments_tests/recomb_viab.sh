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
