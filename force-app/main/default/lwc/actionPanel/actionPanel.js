import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import advanceApproval from '@salesforce/apex/EngagementController.advanceApproval';

export default class ActionPanel extends LightningElement {
    @api engagementId;
    @api statistics;

    isAdvancing = false;

    get hasStatistics() {
        return !!this.statistics;
    }

    get approvalComplete() {
        return (
            this.statistics &&
            this.statistics.totalApprovalStepCount > 0 &&
            this.statistics.completedApprovalStepCount === this.statistics.totalApprovalStepCount
        );
    }

    get isAdvanceDisabled() {
        return this.isAdvancing || this.approvalComplete;
    }

    async handleAdvanceApproval() {
        this.isAdvancing = true;
        try {
            await advanceApproval({ engagementId: this.engagementId });
            this.dispatchEvent(new CustomEvent('approvaladvanced'));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Approval step advanced.',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Unable to advance approval',
                    message: error?.body?.message || 'An unexpected error occurred.',
                    variant: 'error'
                })
            );
        } finally {
            this.isAdvancing = false;
        }
    }
}
