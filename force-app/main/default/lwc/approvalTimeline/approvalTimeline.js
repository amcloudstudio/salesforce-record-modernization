import { LightningElement, api } from 'lwc';

const ICON_BY_STATUS = {
    Approved: 'utility:success',
    Rejected: 'utility:error',
    'In Progress': 'utility:clock',
    Pending: 'utility:date_input'
};

const VARIANT_BY_STATUS = {
    Approved: 'success',
    Rejected: 'error',
    'In Progress': 'warning',
    Pending: 'inverse'
};

export default class ApprovalTimeline extends LightningElement {
    @api steps = [];

    get hasSteps() {
        return this.steps && this.steps.length > 0;
    }

    get formattedSteps() {
        return (this.steps || []).map((step) => ({
            ...step,
            iconName: ICON_BY_STATUS[step.status] || 'utility:date_input',
            badgeClass: `slds-badge slds-theme_${VARIANT_BY_STATUS[step.status] || 'inverse'}`
        }));
    }
}
