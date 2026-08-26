import type {TruckTank} from '$lib/types/truck';

export const makeTank = (overrides: Partial<TruckTank> = {}): TruckTank =>
  ({
    id: 1,
    truckId: 1,
    plateNumber: 'CIT-001',
    vin: null,
    make: null,
    model: null,
    year: null,
    capacity: 30_000,
    status: 'active',
    conformityCertificateExpiresOn: null,
    conformityCertificateDaysRemaining: null,
    ...overrides,
  }) as TruckTank;
