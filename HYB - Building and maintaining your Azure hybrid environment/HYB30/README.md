# HYB30 - Maintaining your Azure Environment

Azure Automation offers configuration, maintenance, and monitoring solutions that work within your Azure cloud and also your on-premises data center. Using Azure Automation, you can enforce system configuration, detect and alert on configuration drift, and auto remediate configuration issues. In this session, you will learn how to manage the state and configuration of both Windows and Linux systems using Azure Automation.

## NOTE: 

All services created will incur usage costs that you, the replicator of the demo detailed below, will incur. Please be aware the you, the replicator of the demo detailed below, will be responsible for all costs associated in replicating, operating and maintaining this demonstration. Microsoft takes no responsibility of any costs incurred while replicating, operating and maintaining this demonstration. It is advised to turn off or terminate the replicated demonstration once completed to ensure incurred costs are kept to a minimum.  

## Deploy Azure infrastructure

Deploy this template at least 6 hours prior to demonstration. You need an Azure Service Principle and Tenant ID for the deployment. See [Create an Azure service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest) for detailed information.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fneilpeterson%2Fazure-automation-dsc%2Fmaster%2Fazure-templates%2FazureDeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Manual configuration and prep

Once the environment is ready to go, these steps need to be manually performed.

- In Azure Automaton [update the Windows Service caching](https://docs.microsoft.com/en-us/azure/automation/automation-vm-inventory) from 30 min to 10 seconds.
- In Azure Automation, [configure the storage account](https://docs.microsoft.com/en-us/azure/automation/change-tracking-file-contents) for storing file diffs.
- Update `host` file on Linux system.

## Demo 1 - Configuration, State, Alert

**Prep:**

- Stop IIS on VM, this will surface later in the demos

**DSC:**

- Step through DSC Solution
- [Create](./support-scripts/Import-dsc-configuration.ps1) and [compile](./support-scripts/compile-dsc-configuration.ps1) DSC configuration (scripted)
- Reassign VM to new configuration (manual)

**Inventory and State Tracking:**

- Step through the Inventory and Change Tracking solutions
- Show IIS services in Inventory (should see one stopped)
- Show detected IIS failure in state tracking

## Demo 2 - Log Analytics and Alert

**Monitor Logs Dashboarding**

- Go back through change tracking, show IIS failure again
- Create Log Analytics query to surface systems with failed IIS, pin to Dashboard

**Log analytics query for dashboard:**

```
ConfigurationChange
| where ConfigChangeType == "WindowsServices"
| where SvcName == "W3SVC"
| where SvcState == "Stopped"
| summarize count() by Computer, bin(TimeGenerated, 7d)
| render piechart
```

**Log Analytics and simple alert**

- Create Log Analytics query to surface failed IIS
- Create alert based on query
- Create action group to send email
- Create action group to trigger runbook

**Log analytics query for alert**

```
ConfigurationChange
| where ConfigChangeType == "WindowsServices"
| where SvcName == "W3SVC"
| where SvcState == "Stopped"
| project Computer
```

**Stop IIS on VM**

At this point, stop IIS on a VM. Once completed cary on with these steps while giving the alert action groups an opportunity to run.

**File diff**

This is not IIS-related, but a cool solution.

- Show file change solution and changed Linux host contents
- Create log analytics query to surface file changes*

**Log analytics query for alert:**

```
ConfigurationChange
| where ConfigChangeType == "Files"
| where FileSystemPath == "/etc/host.conf"
```

**Azure Automation**

- Show Runbook solution
- Show Runbook in detail
- Show pre-created job logs
- Show pre-created Teams message
- Show that the initial that the service that was initially stopped has been started

## Teardown Instructions (after demo completion)

Deleting the resource group will also delete all related Azure objects.

## Learn More/Resources

[Azure Automation Documentation](https://docs.microsoft.com/en-us/azure/automation/?WT.md_id=MSIgniteTheTour-github-hyb30)

[Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/?WT.md_id=MSIgniteTheTour-github-hyb30)
