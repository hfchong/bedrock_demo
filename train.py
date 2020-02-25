import logging
from bedrock_client.bedrock.api import BedrockApi
import shlex
import os
import subprocess
import re
import shutil

logger = logging.getLogger(__name__)
bedrock = BedrockApi(logger)

def log_learnloss(output):
    bedrock.log_metric("loss", float(re.search('(?<=, ).*(?= avg)', output).group().strip()))
    bedrock.log_metric("loss_iteration", int(re.search("\d*", output.split()[0]).group().strip()))
    bedrock.log_metric("learn", float(re.search('(?<=loss, ).*(?= rate)', output).group().strip()))
    bedrock.log_metric("learn_iteration", int(re.search("\d*", output.split()[0]).group().strip()))

def run_command(command):
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE, encoding='utf8')
    temp_map_val = ""
    map_ctr = 0
    while True:
        output = process.stdout.readline()

        if output == '' and process.poll() is not None:
            break

        elif "mean average precision (mAP@0.50)" in output:
            map_ctr = 1
            temp_map_val = output

        elif map_ctr >= 1:
            if 'avg loss' in output:
                bedrock.log_metric("mAP", float(temp_map_val.split()[7]));
                bedrock.log_metric("mAP_iteration_number", int(output.split(":")[0].strip()) - 1)
                log_learnloss(output)
                map_ctr = 0
                temp_map_val = ""

            elif map_ctr > 0 and map_ctr < 400:
                map_ctr += 1

            else:
                map_ctr = 0
                temp_map_val = ""

        elif re.search('(?<=, ).*(?= avg)', output):
            log_learnloss(output)

    rc = process.poll()
    return rc


weight = os.getenv('weights', 'darknet.conv.74')
gpus = os.getenv('weights', 'darknet.conv.74')
cfg = os.getenv('cfg', 'yolov3/cfg')
data = os.getenv('data', 'yolo')
path = os.getenv('path', './')
destination = '/root/darknet'

url = "http://pjreddie.com/media/files/darknet53.conv.74"

# subprocess.run(["wget", "-O", path + url.split("/")[-1], url])

# dest = shutil.move(path, destination)

# subprocess.run(["/root/darknet", "detector", "train", "data/" + data, cfg, weight, "-gpus", gpus, "-map"])
os.chdir("/home/nazar/NeuralNetworkFramework/Darknet")
print(os.getcwd())
run_command("./darknet detector map data/rotifer.data rotifer_exp01.cfg rotifer_exp01_best.weights")

# Log metrics
# bedrock.log_metric("Accuracy", acc)
