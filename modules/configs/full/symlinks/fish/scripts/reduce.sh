#!/usr/bin/env bash
#Reduce video file size
#Usage: ./reduce run

option=0
type=mp4
out=output.$type
bitrate=0
thread=0
#    -threads 0 (optimal);
#    -threads 1 (single-threaded);
#    -threads 2 (2 threads for e.g. an Intel Core 2 Duo);
#    none (the default, also optimal).
#see: https://superuser.com/questions/155305/how-many-threads-does-ffmpeg-use-by-default

function run(){
    clear
    echo "==================================="
    echo "    Script to reduce video size    "
    echo "==================================="
    echo
    read -p "Process loop count: " count
    echo
    options
    read -p "Debug(false): " debug
    for (( i=1; i<=$count; i++ )) # for i in {1..$count} does not work 
    do
        echo
        echo "loop count:"$i
        if [ "$i" = 1 ]; then
            if [[ -e "$out" ]]; then
                rm $out
            fi
            in=$(ls -a | grep .$type)
        fi

        if [ "$option" = 1 ]; then                             #default_ffmpeg_processing
            cmd="ffmpeg -i $in $out"
        elif [ "$option" = 2 ]; then                           #general
            cmd="ffmpeg -i $in -c:v libx265 -crf 28 $out"
        elif [ "$option" = 3 ]; then                           #reduce bitrate
            if [ "$x" = 1]; then
                read -p "specify bitrate: " bitrate
            fi
            cmd="ffmpeg -i $out -b $bitrate $out" 
        elif [ "$option" = 4 ]; then                           #vary CRF
            if [ "$x" = 1]; then
                read -p "specify CRF value(23): " value
            fi
            cmd="ffmpeg -i $in -vcodec libx264 -crf $value $out"
        elif [ "$option" = 5 ]; then                           #reduce size
            if [ "$x" = 1]; then
                read -p "reduce video screen-size by(2=half its pixel size): " value
            fi
            cmd="ffmpeg -i $in -vf "scale=iw/$value:ih/$value" $out"
        elif [ "$option" = 6 ]; then                           #H.264_profile_to_"baseline"
            cmd="ffmpeg -i $in -profile:v baseline $out"
        else
            echo "Invalid Choice."
            read -p "Press enter to retry .."
            if [ "$key" = '' ]; then
                run
            fi
        fi

        if [ "$debug" = true ]; then
            $cmd -threads $thread
        else
            $cmd -threads $thread &> /dev/null
        fi
        
        if [[ -e "input.$type" ]]; then
            rm input.$type
        fi
        if [ "$i" != $count ]; then
            mv $out input.$type
            in=input.$type
        fi
    
    done
    echo "Complete !"
    echo "More info: https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg"
    exit
}

options(){
    echo "Choose a Method: "
    methods="1.default_ffmpeg_processing 2.general 3.reduce_bitrate 4.vary_C_R_F 5.reduce_size 6.H.264_profile_to_"baseline""
    for x in $methods
    do
        echo $x
    done
    echo
    read -p "Choice: " option
    echo
}

"$@"
