import { LightningElement, api } from 'lwc';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'name', type: 'text' },
    { label: 'Industry', fieldName: 'industry', type: 'text' },
    { label: 'Relationship', fieldName: 'relationshipType', type: 'text' }
];

export default class RelatedAccounts extends LightningElement {
    @api accounts = [];
    columns = COLUMNS;

    get hasAccounts() {
        return this.accounts && this.accounts.length > 0;
    }
}
