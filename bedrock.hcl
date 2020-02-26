 // Refer to https://docs.basis-ai.com/getting-started/writing-files/bedrock.hcl for more details.
version = "1.0"

train {
    step train {
        image = "zarraozaga/alexyab_darknet:bedrock"
        install = ["pip3 install -r requirements-train.txt"]
        script = [
            {
                sh = ["gsutil cp gs://bdrk-govtech-va-temp/data/data.tar.xz . && tar xf data.tar.xz && pwd"]
            }
        ]
        resources {
            gpu = 0
            cpu = "500m"
            memory = "500M"
        }
    }

    parameters {
        weights = "darknet.conv.74"
        gpus = "0"
        cfg = "my_string_2"
        data = "my_string_3"
        path = "/root/bedrock"
    }
}