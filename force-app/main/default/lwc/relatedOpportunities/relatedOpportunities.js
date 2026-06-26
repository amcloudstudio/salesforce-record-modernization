import { LightningElement, api } from 'lwc';

const COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'name', type: 'text' },
    { label: 'Stage', fieldName: 'stageName', type: 'text' },
    { label: 'Amount', fieldName: 'amount', type: 'currency' },
    { label: 'Close Date', fieldName: 'closeDate', type: 'date-local' }
];

export default class RelatedOpportunities extends LightningElement {
    @api opportunities = [];
    columns = COLUMNS;

    get hasOpportunities() {
        return this.opportunities && this.opportunities.length > 0;
    }
}
