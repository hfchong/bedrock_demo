train {

    step train {
        image = "basisai/workload-standard"
        install = ["chmod +x training.sh"]
        script = [
            {
                sh = ["python3 train.py"]
            }
        ]
        resources {
            gpu = 1
            cpu = "500m"
            memory = "500M"
        }
    }

    parameters {
        weight = "darknet53.conv.74"
        cfg = "yolov3.cfg"
        data = ""
        logfile = ""
    }
}