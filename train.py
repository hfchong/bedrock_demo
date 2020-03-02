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


def run_command(command, logfile):
    logfile.write("This is the run command: %s\n" % command)
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE, encoding='utf8')
    currentMAP = 0.0
    currentIterationNumber = 0
    while True:
        output = process.stdout.readline()
        logFile.write(output + "\n")
        if output == '' and process.poll() is not None:
            break

        elif (currentMAP >= float(os.environ['MAP_STOP'])) or (currentIterationNumber >= int(os.environ['ITERATIONS_STOP'])):
            logFile.write("Current iteration number: %d\n" % (currentIterationNumber))
            logFile.write("Current mAP :%f\n" % (currentMAP))
            break

        elif output == '':
            continue

        elif "mean average precision (mAP@0.50)" in output:
            bedrock.log_metric("mAP", float(output.split()[7]));
            currentMAP = float(output.split()[7])

        elif re.search('(?<=, ).*(?= avg)', output):
            currentIterationNumber = int(re.search("\d*", output.split()[0]).group().strip())
            log_learnloss(output)

    print("Training Ended")

    rc = process.poll()
    return rc


logFile = open(os.environ['LOGFILE'], "a+")

os.chdir("/root/darknet")
logFile.write("Current working directory: %s\n" % (os.getcwd()))
logFile.write("Weights :%s\n" % (os.environ['WEIGHTS']))
logFile.write("CFG :%s\n" % (os.environ['CFG']))
logFile.write("DATA :%s\n" % (os.environ['DATA']))
logFile.write("Stop at iteration number: %s\n" % (os.environ['ITERATIONS_STOP']))
logFile.write("Stop at mAP :%s\n" % (os.environ['MAP_STOP']))

run_command("./darknet detector train data/%s %s %s -map" % (os.environ['DATA'], os.environ['CFG'], os.environ['WEIGHTS']), logFile)

logFile.close()
