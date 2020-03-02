#!/bin/sh
touch ${LOGFILE}

echo "Google Cloud SDK"
source /root/google-cloud-sdk/path.bash.inc

echo "Copying Data from GCP to /app"
gsutil cp gs://bdrk-govtech-va-temp/experiment.tar.xz .

echo "Unzipping Experiment folder"
tar xf experiment.tar.xz

echo "Current Directory" >> ${LOGFILE}
pwd >> ${LOGFILE}
ls -la >> ${LOGFILE}

echo "Deleting all weights and cfg from /root/darknet"
rm -f /root/darknet/*.weights
rm -f /root/darknet/*.cfg

echo "Copying Weights Over from /app/weights to /root/darknet" >> ${LOGFILE}
cp -r /app/experiment/weights/. /root/darknet
ls -t /root/darknet/*.weights | head -n 1 >> ${LOGFILE}
export WEIGHTS=$(basename $(ls -t /app/experiment/weights/ | head -n 1))


echo "Copying CFG Over from /app/cfg to /root/darknet" >> ${LOGFILE}
cp -r /app/experiment/cfg/. /root/darknet
ls -t /root/darknet/*.cfg | head -n 1 >> ${LOGFILE}
export CFG=$(basename $(ls -t /root/darknet/*.cfg | head -n 1))

echo "Copying Data files Over from /app/data to /root/darknet/data/" >> ${LOGFILE}
cp -r /app/experiment/data /root/darknet/
ls -t /root/darknet/data/*.data | head -n 1 >> ${LOGFILE}
export DATA=$(basename $(ls -t /root/darknet/data/*.data | head -n 1))

echo "Preparing for training, logging to ${LOGFILE}" >> ${LOGFILE}
nvidia-smi >> ${LOGFILE}

mv /app/train.py /root/darknet/

cd /root/darknet

python3 train.py
#
#cd /root/darknet
#
#./darknet detector train data/rotifer.data ./$rotifer_exp06.cfg ./darknet53.conv.74 -dont_show -map >> ${LOGFILE}