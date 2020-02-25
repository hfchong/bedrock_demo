#!/bin/sh

echo "Creating Images Path Files"
chmod +x ${MOUNT_PATH}/images_path.sh
${MOUNT_PATH}/images_path.sh

echo "Copying Weights Over from ${MOUNT_PATH}/weights to ${DARKNET_ROOT}/"
cp -r ${MOUNT_PATH}/weights/. ${DARKNET_ROOT}/

echo "Copying CFG Over from ${MOUNT_PATH}/cfg to ${DARKNET_ROOT}/"
cp -r ${MOUNT_PATH}/cfg/. ${DARKNET_ROOT}/

echo "Copying Data files Over from ${MOUNT_PATH}/data to ${DARKNET_ROOT}/data/"
cp -r ${MOUNT_PATH}/data ${DARKNET_ROOT}/

echo "Preparing for training, logging to ${LOGFILE}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "GPUS ID: ${GPU}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "Weights: ${WEIGHT}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "CFG: ${CFG}" >> ${MOUNT_PATH}/logs/${LOGFILE}
echo "DATA: ${DATA}" >> ${MOUNT_PATH}/logs/${LOGFILE}
cat ./data/${DATA} >> ${MOUNT_PATH}/logs/${LOGFILE}

./darknet detector train data/${DATA} ./${CFG} ./${WEIGHT} -gpus ${GPU} -dont_show -map >> ${MOUNT_PATH}/logs/${LOGFILE}


tail -f /dev/null
