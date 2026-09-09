# Override defaults from variables.tf here if needed for a given run.
# Left mostly empty on purpose - variables.tf already defaults everything to
# the assignment-{resource} sandbox configuration.
aws_region  = "us-east-1"
name_prefix = "assignment-shuttle-bus"

# Set this to your own email to receive CloudWatch alarm notifications via
# SNS. AWS sends a confirmation email after the first `terraform apply` -
# you must click "Confirm subscription" in it before alerts actually arrive.
alert_email = "yapjj123@gmail.com"
