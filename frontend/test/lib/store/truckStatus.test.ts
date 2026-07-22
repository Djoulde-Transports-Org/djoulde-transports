import {truckStatusMeta, truckStatusFilters} from '$lib/store/truckStatus';

describe('truckStatusMeta', () => {
  it('maps every truck status to a singular label and classes', () => {
    expect(truckStatusMeta.on_trip.label).toBe('En route');
    expect(truckStatusMeta.in_maintenance.label).toBe('Maintenance');
    expect(truckStatusMeta.ready.label).toBe('Prêt');
  });
});

describe('truckStatusFilters', () => {
  it('starts with a Tous chip that clears the status filter', () => {
    expect(truckStatusFilters[0]).toEqual({key: 'status', label: 'Tous', value: ''});
  });

  it('includes one chip per truck status', () => {
    const values = truckStatusFilters.map((chip) => chip.value);
    expect(values).toEqual(['', 'on_trip', 'in_maintenance', 'ready']);
  });

  it('pluralizes the ready status to Prêts for the filter chip', () => {
    const readyChip = truckStatusFilters.find((chip) => chip.value === 'ready');
    expect(readyChip?.label).toBe('Prêts');
  });

  it('reuses the singular badge label for statuses without an override', () => {
    const onTripChip = truckStatusFilters.find((chip) => chip.value === 'on_trip');
    expect(onTripChip?.label).toBe('En route');
  });
});
