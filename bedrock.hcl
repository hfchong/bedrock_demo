// Refer to https://docs.basis-ai.com/getting-started/writing-files/bedrock.hcl for more details.
version = "1.0"

/*
Train stanza
Comprises the following:
- [required] step: training steps to be run. Multiple steps are allowed but must have different names
- [optional] parameters: environment variables used by the script. They can be overwritten when you create a run.
- [optional] secrets: the names of the secrets necessary to run the script successfully
Step stanza
Comprises the following:
- [required] image: the base Docker image that the script will run in
- [optional] install: the command to install any other packages not covered in the image
- [required] script: the command that calls the script
- [optional] resources: the computing resources to be allocated to this run step
- [optional] depends_on: a list of names of steps that this run step depends on
*/
train {
    // We declare a step with a step name. For example, this step is named as "preprocess".
    // A step's name must be unique.

    step train {
        image = "hfchong/darknet:v0.1.0"
        install = ["pip3 install -r requirements-train.txt"]
        script = [
            {
                //sh = ["ls /root && source /root/google-cloud-sdk/path.bash.inc && gsutil cp gs://bdrk-govtech-va-temp/rotifer_exp_06.tar.xz . && tar xf rotifer_exp_06.tar.xz && pwd && ls"]
                sh = ["chmod a+x train.sh && ./train.sh"]
            }
        ]
        resources {
            cpu = "2900m"
            memory = "11500M"
            gpu = "1"
        }
    }

    parameters {
        LOGFILE = "/artefact/experiment_log.txt"
        ITERATIONS_STOP = "10"
        MAP_STOP = "70.5"
    }
}