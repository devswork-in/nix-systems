#!/usr/bin/env bash

read -p "Give video location: " vid;
read -p "After how many sec should i save a new pic : " sec;
mkdir output;
echo 'working ...';
ffmpeg -i $vid -r 1/$sec output/image-%04d.png &> /dev/null;

echo 'Done !'

# https://www.thewindowsclub.com/extract-frames-from-a-video-with-high-quality
# https://stackoverflow.com/questions/10957412/fastest-way-to-extract-frames-using-ffmpeg
