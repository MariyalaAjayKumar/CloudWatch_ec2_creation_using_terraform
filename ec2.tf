resource "aws_instance" "linux" {

    ami ="ami-08f9a9c699d2ab3f9"
    instance_type = "t2.micro"
    key_name = "testing"
    subnet_id="subnet-0768fedc56185694f"
    tags = {
        Name = "Demo_server"
    }
}