# Automated Incident Response System

A Python-based incident response tool that monitors AWS GuardDuty 
for security findings and responds by isolating affected resources 
and preserving forensic evidence.

## What I set out to solve

Most cloud security tools focus on detection. When a threat is 
confirmed, the response is often manual - an analyst reads the 
finding, decides what to do, and acts. This project automates 
the containment and evidence preservation steps so the response 
is consistent and fast regardless of who is on call.

My background in digital forensics at Lincolnshire Police taught 
me that evidence captured after containment may be compromised. 
This system captures evidence first, before any containment action.

## What I implemented

- Connects to GuardDuty and retrieves findings above a severity threshold
- Opens a case with a unique ID and UTC timestamp for each finding
- Captures the state of affected EC2 instances before taking action
- Attempts to isolate compromised instances by moving them to a 
  dedicated security group with no ingress or egress rules
- Saves a timestamped evidence package to S3 with AES-256 encryption
- Maintains a chain of custody log recording every action taken
- Includes a Lambda handler for event-driven deployment

## What was actually tested

The script was run against a live AWS account with GuardDuty sample 
findings enabled. Two findings were processed:

- UnauthorizedAccess:IAMUser/MaliciousIPCaller - case opened, 
  isolation attempted (failed on sample instance i-99999999 as 
  expected - sample findings use fake instance IDs)
- Policy:IAMUser/RootCredentialUsage - case opened, evidence 
  captured and saved to S3 successfully

Evidence packages were confirmed in S3 with correct encryption.
The Lambda handler function exists in the code but full EventBridge 
triggered deployment has not been tested end to end.

## Why I chose this approach

Evidence capture before containment reflects forensic best practice. 
In a real investigation, instance state at the time of detection is 
more valuable than state after isolation. The chain of custody log 
means every action is timestamped and attributable.

Security group isolation was chosen over instance termination because 
it preserves the instance for forensic analysis while preventing 
lateral movement.

## Response sequence

1. GuardDuty finding detected above severity threshold
2. Case ID generated with UTC timestamp
3. Instance state captured - security groups, launch time, running state
4. Chain of custody record opened
5. Isolation security group created
6. Instance moved to isolation security group
7. Isolation result logged to chain of custody
8. Complete evidence package saved to S3 with AES-256 encryption

## Resource types handled

The current implementation handles EC2 instance findings. GuardDuty 
findings that do not reference an EC2 instance (such as IAM credential 
findings) still have a case opened and evidence captured from the 
finding itself, but no instance isolation is attempted.

## Chain of custody limitations

The evidence package is a timestamped JSON record of actions taken 
and resource state observed. It is useful for incident tracking and 
audit purposes. It is not cryptographic proof of evidence integrity - 
no hash verification is implemented in the current version. In a 
formal investigation the evidence would need additional integrity 
verification.

## Operational considerations

This tool was built for a personal learning environment. Before 
using in a real environment, the following would need
