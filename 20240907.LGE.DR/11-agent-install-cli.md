



```
aws ssm send-command --document-name "AWSDisasterRecovery-InstallDRAgentOnInstance" --document-version "13" --targets '[{"Key":"tag:DRS","Values":["True"]},{"Key":"tag:Name","Values":["DR-ID-Web-Home","DR-ID-Web-Contact"]}]' --parameters '{"Region":["us-east-1"],"Tags":[""]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --region us-west-2
```





```
aws ssm send-command --document-name "AWSDisasterRecovery-InstallDRAgentOnInstance" --document-version "13" --targets '[{"Key":"InstanceIds","Values":["i-08d979ba06e2cbeba","i-0a567cc5b802a2031"]}]' --parameters '{"Region":["us-east-1"],"Tags":[""]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --region us-west-2
```

