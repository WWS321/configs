#! /bin/bash

declare -A cksKedaya
declare -A cksDocker
declare -A cksChanged
fileKedaya="/home/ubuntu/kedaya/cookie/jd.js"
fileDocker="/home/ubuntu/jdauto/docker-compose.yml"

# Finds cookies from the file 'fileDocker' and then pushs them to the map 'cksDocker'
if [ -f $fileDocker ];then
    while read line
    do
        resultCnpare=$(echo ${line} | grep "pt_pin\|pt_key*")
        if [ -n "$resultCnpare" ];then
            keyTemp=$(echo $line | grep -Eo "jd_[^;]+")
            valTemp=$(echo $line | grep -Eo "(AA|app)[^;]+")
            cksDocker[$keyTemp]=$valTemp
        fi
    done < $fileDocker
else
    echo -e `date '+%b %d %T %A':` "Can't find $fileDocker !!!"
fi    

# Finds cookies from the file 'fileKedaya' and then pushs them to the map 'cksKedaya'
if [ -f $fileKedaya ];then
    while read line
    do
        resultCnpare=$(echo ${line} | grep "pt_pin\|pt_key*")
        if [ -n "$resultCnpare" ];then
            keyTemp=$(echo $line | grep -Eo "jd_[^;]+")
            valTemp=$(echo $line | grep -Eo "(AA|app)[^;]+")
            cksKedaya[$keyTemp]=$valTemp
        fi
    done < $fileKedaya
else
    echo -e `date '+%b %d %T %A':` "Can't find $fileKedaya !!!"
fi    

# Finds the difference between two maps(cksDocker,cksKedaya)
isChanged=0
for key in ${!cksDocker[@]}; do
    if [ -n $key ];then
        for keyKdy in ${!cksKedaya[@]}; do
            if [[ -n $keyKdy && $keyKdy == $key && ${cksKedaya[$keyKdy]} != ${cksDocker[$key]} ]];then
                cksChanged[$key]=${cksKedaya[$keyKdy]}
                isChanged=1
                break  
            fi
        done
    else
        echo -e `date '+%b %d %T %A':` "key string lenth is zero!!!"    
    fi    
done

# echo "isChanged flag: ${isChanged}"
# echo "cksChanged keys: ${!cksChanged[@]}"
# echo "cksChanged vals: ${cksChanged[@]}" 

# update cks in docker-compose.yml if jd.js changed!
if [ -f $fileDocker ] && [ 1 -eq $isChanged ]
then
    for key in ${!cksChanged[@]}
    do
        sed -Ei "s/(AA|app).+pt_pin=$key/${cksChanged[$key]};pt_pin=$key/" $fileDocker
        echo -e `date '+%b %d %T %A':` "Ck Updated: ${key}"
    done

    cd /home/ubuntu/jdauto
    docker-compose up -d --remove-orphans
    echo -e `date '+%b %d %T %A':` 'Docker restarted!!!'

elif [ ! -f $fileDocker ]
then
    echo -e `date '+%b %d %T %A':` "Cant find the file: $fileDocker !!!"
else
    echo -e `date '+%b %d %T %A':` "Cks are same~"
fi
