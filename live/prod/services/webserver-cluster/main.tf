provider "aws" {
    region = "us-east-2"
  
}

module "webserver_cluster" {
    #pulling the module from github instead of my local machine
    source = "github.com/oliviambrown/terraform-up-running//modules/services/webserver-cluster/"

    cluster_name = "webservers-prod"
    db_remote_state_bucket = var.db_remote_state_bucket
    db_remote_state_key = var.db_remote_state_key

    instance_type = "m4.large"
    min_size = 2
    max_size = 10

    custom_tags = {
        Owner = "team-foo"
        ManagedBy = "terraform"
    }
  
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 10
    desired_capacity = 10
    recurrence = "0 9 * * *"

    autoscaling_group_name = module.webserver_cluster.asg_name
  
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    scheduled_action_name = "scale-in-at-night"
    min_size = 2
    max_size = 10
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = module.webserver_cluster.asg_name
  
}