import type {Maintenance} from '$lib/types/maintenance';

export const makeMaintenance = (overrides: Partial<Maintenance> = {}): Maintenance =>
  ({
    id: 1,
    truckId: 1,
    performedById: null,
    kind: 'routine',
    state: 'started',
    performedOn: '2026-06-25',
    cost: null,
    odometerKm: null,
    estimatedDuration: null,
    actualDuration: null,
    duration: null,
    description: null,
    truck: {id: 1, plateNumber: 'TRK-001'},
    technician: null,
    ...overrides,
  }) as Maintenance;
