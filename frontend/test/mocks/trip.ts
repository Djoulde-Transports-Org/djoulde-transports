import type {Trip} from '$lib/types/trip';
import {makeTruck} from './truck';

export const makeTrip = (overrides: Partial<Trip> = {}): Trip =>
  ({
    id: 1,
    status: 'in_progress',
    cargo_description: null,
    distance_km: null,
    scheduled_start_at: '2026-06-25T08:00:00Z',
    scheduled_end_at: null,
    actual_start_at: null,
    actual_end_at: null,
    truck: makeTruck(),
    driver: null,
    route: {id: 1, origin: 'Conakry', destination: 'Mamou', rate: 1500},
    delivery_note: null,
    billing_statement: null,
    ...overrides,
  }) as Trip;
