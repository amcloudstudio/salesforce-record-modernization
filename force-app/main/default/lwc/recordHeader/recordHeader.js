import { LightningElement, api } from 'lwc';

const STATUS_BADGE_VARIANT = {
    New: 'inverse',
    'In Review': 'warning',
    Approved: 'success',
    Rejected: 'error',
    Closed: 'inverse'
};

export default class RecordHeader extends LightningElement {
    @api engagement;

    get statusBadgeClass() {
        const variant = STATUS_BADGE_VARIANT[this.engagement?.status] || 'inverse';
        return `slds-theme_${variant} slds-badge`;
    }
}
