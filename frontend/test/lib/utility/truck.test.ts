import {formatTruckModel, formatTankSummary, truckDocumentRows} from '$lib/utility/truck';
import {makeTruck} from '../../mocks/truck';

describe('formatTruckModel', () => {
  it('combines make, model and year', () => {
    expect(formatTruckModel(makeTruck({make: 'Volvo', model: 'FH', year: 2019}))).toBe(
      'Volvo FH · 2019'
    );
  });

  it('returns — when make, model and year are all missing', () => {
    expect(formatTruckModel(makeTruck({make: null, model: null, year: null}))).toBe('—');
  });

  it('omits missing parts but keeps the ones present', () => {
    expect(formatTruckModel(makeTruck({make: null, model: null, year: 2020}))).toBe('2020');
  });
});

describe('formatTankSummary', () => {
  it('returns — when there is no tank', () => {
    expect(formatTankSummary(null)).toBe('—');
  });

  it('combines the tank plate number and capacity', () => {
    const summary = formatTankSummary({
      id: 1,
      truckId: 1,
      plateNumber: 'TC-041',
      vin: null,
      make: null,
      model: null,
      year: null,
      capacity: 33_000,
      status: 'active',
      conformityCertificateExpiresOn: null,
      conformityCertificateDaysRemaining: null,
    });
    // toLocaleString('fr-FR') uses a narrow no-break space (U+202F) as the
    // thousands separator; normalize it before comparing against a plain string.
    const normalized = summary.replace(/\u202f/g, ' ');
    expect(normalized).toBe('TC-041 · 33 000 L');
  });
});

describe('truckDocumentRows', () => {
  it('returns the 6 tracked documents in order with their days remaining', () => {
    const truck = makeTruck({
      truckInsuranceDaysRemaining: 45,
      cargoInsuranceDaysRemaining: 120,
      technicalInspectionDaysRemaining: 8,
      operatingPermitDaysRemaining: 200,
      truckRegistrationDaysRemaining: 330,
      tank: {
        id: 1,
        truckId: 1,
        plateNumber: 'TC-041',
        vin: null,
        make: null,
        model: null,
        year: null,
        capacity: 33_000,
        status: 'active',
        conformityCertificateExpiresOn: null,
        conformityCertificateDaysRemaining: 25,
      },
    });

    expect(truckDocumentRows(truck)).toEqual([
      {label: 'Ass. camion', daysRemaining: 45},
      {label: 'Ass. produit', daysRemaining: 120},
      {label: 'Visite tech.', daysRemaining: 8},
      {label: 'Carte de Transport', daysRemaining: 200},
      {label: 'Carte grise', daysRemaining: 330},
      {label: 'Baremage', daysRemaining: 25},
    ]);
  });

  it('reports the conformity certificate as null when there is no tank', () => {
    const truck = makeTruck({tank: null});
    const baremage = truckDocumentRows(truck).find((doc) => doc.label === 'Baremage');
    expect(baremage?.daysRemaining).toBeNull();
  });
});
