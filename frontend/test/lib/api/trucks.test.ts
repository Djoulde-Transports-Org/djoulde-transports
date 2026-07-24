import {api} from '$lib/api/client';
import {getTrucks, createTruck} from '$lib/api/trucks';
import type {CreateTruckPayload} from '$lib/types/truck';
import {makeTruck} from '../../mocks/truck';

vi.mock('$lib/api/client', () => ({api: {get: vi.fn(), post: vi.fn()}}));

describe('getTrucks', () => {
  afterEach(() => vi.clearAllMocks());

  it('calls api.get with /trucks and the default perPage of 7', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getTrucks();
    expect(api.get).toHaveBeenCalledWith('/trucks?per_page=7');
  });

  it('calls api.get with the supplied perPage', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getTrucks(10);
    expect(api.get).toHaveBeenCalledWith('/trucks?per_page=10');
  });

  it('returns data and null error on success', async () => {
    const trucks = [makeTruck()];
    vi.mocked(api.get).mockResolvedValue(trucks);
    const result = await getTrucks();
    expect(result.data).toEqual(trucks);
    expect(result.error).toBeNull();
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getTrucks();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getTrucks();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Une erreur est survenue.');
  });
});

describe('createTruck', () => {
  afterEach(() => vi.clearAllMocks());

  const payload: CreateTruckPayload = {
    plateNumber: 'NEW-001',
    model: 'FH',
    year: 2024,
    tank: {plateNumber: 'TK-001', capacity: 30_000},
  };

  it('calls api.post with /trucks/create and the payload', async () => {
    vi.mocked(api.post).mockResolvedValue(makeTruck());
    await createTruck(payload);
    expect(api.post).toHaveBeenCalledWith('/trucks/create', payload);
  });

  it('returns data and null error on success', async () => {
    const truck = makeTruck();
    vi.mocked(api.post).mockResolvedValue(truck);
    const result = await createTruck(payload);
    expect(result.data).toEqual(truck);
    expect(result.error).toBeNull();
  });

  it('returns the error message and null data when the API throws', async () => {
    vi.mocked(api.post).mockRejectedValue(new Error('Validation failed'));
    const result = await createTruck(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Validation failed');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.post).mockRejectedValue('oops');
    const result = await createTruck(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
