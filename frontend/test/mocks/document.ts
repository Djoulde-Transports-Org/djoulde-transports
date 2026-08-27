import type {FleetDocument} from '$lib/types/document';

export const makeDocument = (overrides: Partial<FleetDocument> = {}): FleetDocument =>
  ({
    id: 1,
    documentableType: 'Truck',
    documentableId: 1,
    documentableLabel: null,
    documentableDate: null,
    docType: 'truck_insurance',
    number: 'INS-1',
    title: 'Assurance camion 2026',
    issuedOn: '2026-01-01',
    expiresOn: '2027-01-01',
    uploadedById: 1,
    uploadedBy: {id: 1, name: 'Mamadou Diallo'},
    fileAttached: true,
    fileSize: 245_760,
    createdAt: '2026-06-25T10:00:00Z',
    ...overrides,
  }) as FleetDocument;
