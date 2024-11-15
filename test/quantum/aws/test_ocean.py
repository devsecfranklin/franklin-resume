# AWS import Boto3
import boto3
# AWS imports: Import Braket SDK modules
from braket.circuits import Circuit
from braket.aws import AwsDevice
# OS import to load the region to use
import os
os.environ['AWS_DEFAULT_REGION'] = "us-east-1"
# The region name must be configured

# When running in real QPU you must enter the S3 bucket you created
# during on boarding to Braket in the code as follows
my_bucket = f"amazon-braket-your-bucket" # the name of the bucket
my_folder = "YourFolder" # the name of the folder in the bucket
s3_folder = (my_bucket, my_folder)

# Set up device
# https://docs.aws.amazon.com/braket/latest/developerguide/braket-devices.html
device = AwsDevice("arn:aws:braket:::device/qpu/ionq/ionQdevice")

# Create the Teleportation Circuit
circ = Circuit()
# Put the qubit to teleport in some superposition state, very simple
# in this example
circ.h(0)
# Create the entangled state (qubit 1 reamins in Alice while qubit 2
# is sent to Bob)
circ.h(1).cnot(1, 2)
# Teleportation algorithm
circ.cnot(0, 1).h(0)
# Do the trick with deferred measurement
circ.h(2).cnot(0, 2).h(2)  # Control Z 0 -> 2 (developed because
                           # IonQ is not having native Ctrl-Z)
circ.cnot(1, 2)            # Control X 1 -> 2

print(circ)

# Run circuit
result = device.run(circ, s3_folder, shots=1000)

execution_windows = device.properties.service.executionWindows
print(f'{device.name} availability windows are:\n{execution_windows}\n')

# Get id and status of submitted task
result_id = result.id
result_status = result.state()
print('ID of task:', result_id)
print('Status of task:', result_status)

if result_status == "COMPLETED":
   # get measurement shots
   counts = result.result().measurement_counts
   print(counts)
