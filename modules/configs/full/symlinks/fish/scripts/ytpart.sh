#!/usr/bin/env bash
#currently end time+=start time
#will shift to video timestamp

echo "========================================================"
read -p "Give link: " link;
read -p "Give start time(00:00): " start;
read -p "Give end time(00:00): " end;
read -p "Give output file name: " out;
echo "========================================================"
ffmpeg $(youtube-dl -g $link | sed "s/.*/-ss $start -i &/") -t $end -c copy $out.mkv &> /dev/null

echo 'Done !'
