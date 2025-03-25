## COVID-19 Tracking Application in Salesforce Apex

This project includes a COVID-19 tracking application built using Aura Components. The application provides tools to track health status of both individuals and locations, facilitating contact tracing and health monitoring.

### Key Components

#### CTHealthAdmin Component
The CTHealthAdmin component serves as a central management interface for tracking health status data across both people and locations. Its features include:

- Tabbed interface for managing Person and Location records
- Health status metrics dashboard showing counts by status (Green, Yellow, Orange, Red)
- Create, read, update functionality for both Person and Location records
- Search and filter capabilities for locating records
- Automatic refresh when records are created or updated

#### Data Structure
The application works with two main objects:
1. **Person__c** - Individuals with health status information
2. **Location__c** - Physical locations with contamination status

#### User Interface
- Dynamic datatable columns based on selected record type
- Modal forms for creating and editing records
- Color-coded status indicators
- Real-time status metrics

#### Server-Side Controllers
- CTHealthHeaderController - Main controller for health metrics and record operations
- CTRecentChangesController - Handles data retrieval for recent changes
- CTLocationController - Location-specific functionality

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Lightning Aura Components Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/intro_framework.htm)
