import {snakeToCamel, camelToSnake, toCamelCase, toSnakeCase} from '$lib/utility/case';

describe('snakeToCamel', () => {
  it('converts a snake_case key to camelCase', () => {
    expect(snakeToCamel('plate_number')).toBe('plateNumber');
    expect(snakeToCamel('total_liters_delivered')).toBe('totalLitersDelivered');
  });

  it('leaves a key with no underscores unchanged', () => {
    expect(snakeToCamel('status')).toBe('status');
  });
});

describe('camelToSnake', () => {
  it('converts a camelCase key to snake_case', () => {
    expect(camelToSnake('plateNumber')).toBe('plate_number');
    expect(camelToSnake('totalLitersDelivered')).toBe('total_liters_delivered');
  });

  it('leaves a key with no uppercase letters unchanged', () => {
    expect(camelToSnake('status')).toBe('status');
  });
});

describe('toCamelCase', () => {
  it('converts object keys recursively, including nested objects and arrays', () => {
    expect(
      toCamelCase({
        plate_number: 'TRK-001',
        tank: {truck_id: 1, conformity_certificate_expires_on: null},
        documents: [{due_on: '2026-01-01'}],
      })
    ).toEqual({
      plateNumber: 'TRK-001',
      tank: {truckId: 1, conformityCertificateExpiresOn: null},
      documents: [{dueOn: '2026-01-01'}],
    });
  });

  it('leaves non-object values untouched', () => {
    expect(toCamelCase(42)).toBe(42);
    expect(toCamelCase(null)).toBe(null);
    expect(toCamelCase('plate_number')).toBe('plate_number');
  });
});

describe('toSnakeCase', () => {
  it('converts object keys recursively, including nested objects and arrays', () => {
    expect(
      toSnakeCase({
        plateNumber: 'TRK-001',
        tank: {truckId: 1, conformityCertificateExpiresOn: null},
        documents: [{dueOn: '2026-01-01'}],
      })
    ).toEqual({
      plate_number: 'TRK-001',
      tank: {truck_id: 1, conformity_certificate_expires_on: null},
      documents: [{due_on: '2026-01-01'}],
    });
  });

  it('round-trips with toCamelCase', () => {
    const original = {plateNumber: 'TRK-001', driverId: 4};
    expect(toCamelCase(toSnakeCase(original))).toEqual(original);
  });
});
