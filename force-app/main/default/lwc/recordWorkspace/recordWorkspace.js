import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getEngagementWorkspace from '@salesforce/apex/EngagementController.getEngagementWorkspace';

export default class RecordWorkspace extends LightningElement {
    @api recordId;

    workspace;
    error;
    wiredWorkspaceResult;

    @wire(getEngagementWorkspace, { engagementId: '$recordId' })
    wiredWorkspace(result) {
        this.wiredWorkspaceResult = result;
        if (result.data) {
            this.workspace = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.workspace = undefined;
            this.error = result.error?.body?.message || 'Unable to load this engagement.';
        }
    }

    get engagement() {
        return this.workspace?.engagement;
    }

    get relatedAccounts() {
        return this.workspace?.relatedAccounts || [];
    }

    get relatedOpportunities() {
        return this.workspace?.relatedOpportunities || [];
    }

    get approvalSteps() {
        return this.workspace?.approvalSteps || [];
    }

    get statistics() {
        return this.workspace?.statistics;
    }

    get hasError() {
        return !!this.error;
    }

    get hasWorkspace() {
        return !!this.workspace;
    }

    async handleApprovalAdvanced() {
        await refreshApex(this.wiredWorkspaceResult);
    }
}
