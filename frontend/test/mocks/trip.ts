import type {Trip} from '$lib/types/trip';
import {makeTruck} from './truck';

export const makeTrip = (overrides: Partial<Trip> = {}): Trip =>
  ({
    id: 1,
    status: 'in_progress',
    cargoDescription: null,
    distanceKm: null,
    scheduledStartAt: '2026-06-25T08:00:00Z',
    scheduledEndAt: null,
    actualStartAt: null,
    actualEndAt: null,
    truck: makeTruck(),
    driver: null,
    route: {id: 1, origin: 'Conakry', destination: 'Mamou', rate: 1500},
    deliveryNote: null,
    billingStatement: null,
    ...overrides,
  }) as Trip;
