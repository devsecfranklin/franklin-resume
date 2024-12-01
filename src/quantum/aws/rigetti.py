import boto3
from braket.circuits import Circuit
from braket.aws import AwsDevice

device = AwsDevice("arn:aws:braket:::device/qpu/rigetti/Aspen-8")
s3_folder = ("amazon-braket-Your-Bucket-Name", "RIGETTI") # Use the S3 bucket you created during onboarding

bell = Circuit().h(0).cnot(0, 1)
task = device.run(bell, s3_folder)
print(task.result().measurement_counts)
