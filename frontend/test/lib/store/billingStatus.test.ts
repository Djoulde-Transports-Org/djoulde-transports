import {billingStatusMeta, billingStatusFilters} from '$lib/store/billingStatus';

describe('billingStatusMeta', () => {
  it('maps every billing status to a label and classes', () => {
    expect(billingStatusMeta.draft.label).toBe('Brouillon');
    expect(billingStatusMeta.issued.label).toBe('Émise');
    expect(billingStatusMeta.paid.label).toBe('Payée');
    expect(billingStatusMeta.void.label).toBe('Annulée');
  });
});

describe('billingStatusFilters', () => {
  it('starts with a Toutes chip that clears the status filter', () => {
    expect(billingStatusFilters[0]).toEqual({key: 'status', label: 'Toutes', value: ''});
  });

  it('includes one chip per filterable billing status, excluding void', () => {
    const values = billingStatusFilters.map((chip) => chip.value);
    expect(values).toEqual(['', 'draft', 'issued', 'paid']);
  });

  it('pluralizes issued and paid for their filter chips', () => {
    expect(billingStatusFilters.find((chip) => chip.value === 'issued')?.label).toBe('Émises');
    expect(billingStatusFilters.find((chip) => chip.value === 'paid')?.label).toBe('Payées');
  });

  it('reuses the singular badge label for draft', () => {
    expect(billingStatusFilters.find((chip) => chip.value === 'draft')?.label).toBe('Brouillon');
  });
});
