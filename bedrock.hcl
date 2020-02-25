train {
    step preprocess {
        image = "zarraozaga/alexyab_darknet"
        install = ["pip3 install -r requirements-train.txt"]
        script = [
            {
                sh = ["python3 preprocess.py"]
            }
        ]
        resources {
            cpu = "500m"
            memory = "500M"
        }
    }

    step train {
        image = "basisai/workload-standard"
        install = ["pip3 install -r requirements-train.txt"]
        script = [
            {
                sh = ["python3 train.py"]
            }
        ]
        resources {
            cpu = "500m"
            memory = "500M"
        }
        depends_on = ["preprocess"]
    }

    parameters {
        weights = "darknet.conv.74"
        weights_url = ""
        cfg = "my_string_2"
        data = "my_string_3"
        path = "/root/bedrock"
    }

    secrets = [
        "DUMMY_SECRET_A",
        "DUMMY_SECRET_B"
    ]
}