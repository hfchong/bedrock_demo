#!/bin/sh

echo "Copying Weights Over to calculate mAP"
chmod +x ${MOUNT_PATH}/images_path.sh
${MOUNT_PATH}/images_path.sh

rm ./*.weights

echo "Copying Weights and cfg Over from ${MOUNT_PATH}/map_calculation to ${DARKNET_ROOT}/"
cp -r ${MOUNT_PATH}/map_calculation/. ${DARKNET_ROOT}/

echo "Copying Data files Over from ${MOUNT_PATH}/data to ${DARKNET_ROOT}/data/"
cp -r ${MOUNT_PATH}/data ${DARKNET_ROOT}/

echo "Successfully copied data over"
echo "GPUS ID: ${GPU}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "Weights: ${WEIGHT}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "CFG: ${CFG}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "DATA: ${DATA}" >> ${MOUNT_PATH}/logs/${LOGFILE}
cat ./data/${DATA} >> ${MOUNT_PATH}/logs/${LOGFILE}

for w in ./*.weights; do
        i="$(basename -- $w)"
        echo "Generating mAP for ${i}" > ${MOUNT_PATH}/logs/MAP_${i%.*}.txt
        ./darknet detector map data/${DATA} ./${i%.*}.cfg "$w" -i ${GPU} -dont_show >> ${MOUNT_PATH}/logs/MAP_${i%.*}.txt

done
echo "Completed Generating mAP"

