#!/bin/bash

inputfile1=$(readlink -f $1)
inputfile2=$(readlink -f $2)
cd $(dirname $(readlink -f $0))

set -e
source /opt/anaconda/bin/activate root
condaenv="thin-plate-spline"
conda env list | grep $condaenv &>/dev/null
if [[ $? -ne 0 ]]; then
    needssetup=1
    conda create --name $condaenv python=3.9
fi
conda activate $condaenv

if [[ "$needssetup" -eq 1 ]]; then
    mkdir -p checkpoints
    pip3 install torch torchvision torchaudio
    pip install -r requirements.txt
fi
run()
{
    python demo.py --config config/vox-256.yaml \
        --checkpoint checkpoints/vox.pth.tar --source_image $1 \
        --driving_video $2 --find_best_frame --result_video $1_ts_$(date +%s).mp4
    python demo.py --mode avd --config config/vox-256.yaml \
        --checkpoint checkpoints/vox.pth.tar --source_image $1 \
        --driving_video $2 --find_best_frame --result_video $1_ts_avd_$(date +%s).mp4
}

if [[ -z "$inputfile1" ]]; then
    echo run this script with run.sh image.png video.mp4
fi

if [[ -z "$inputfile2" ]]; then
    echo run this script with run.sh image.png video.mp4
fi

run "$inputfile1" "$inputfile2"
