import { LightningElement, wire, track } from 'lwc';
import loadPicklistValues from '@salesforce/apex/ProductSearchController.loadPicklistValues';
import searchProductAvailabilityAsync from '@salesforce/apexContinuation/ProductSearchController.searchProductAvailabilityAsync';

export default class ProductSearch extends LightningElement {
    regionOptions = [];
    productOptions = [];
    selectedRegion = '';
    selectedProducts = [];
    results = [];
    error = '';
    loading = false;

    columns = [
        { label: 'SKU', fieldName: 'sku' },
        { label: 'Warehouse', fieldName: 'warehouse' },
        { label: 'Availability', fieldName: 'availability' },
        { label: 'Status', fieldName: 'status' }
    ];
    

    @wire(loadPicklistValues)
    wiredPicklistData({ error, data }) {
        if (data) {
            this.regionOptions = data.regions.map(r => ({
                label: r.Region_Name__c,
                value: r.Region_Name__c
            }));
            this.productOptions = data.products.map(p => ({
                label: `${p.Name} (${p.StockKeepingUnit})`,
                value: p.StockKeepingUnit
            }));
        } else if (error) {
            this.error = 'Failed to load picklist values';
        }
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
    }

    handleProductChange(event) {
        this.selectedProducts = event.detail.value;
    }

    handleSearch() {
        this.loading = true;
        this.error = '';
        this.results = [];

        searchProductAvailabilityAsync({productSKUs : this.selectedProducts, region : this.selectedRegion})
            .then(response => {
                this.results = response;
                this.loading = false;
            })
            .catch(err => {
                this.error = err.body.message || 'An unexpected error occurred';
                this.loading = false;
            });
    }
}