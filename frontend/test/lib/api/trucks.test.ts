import {api} from '$lib/api/client';
import {getTrucks, getAllTrucks, createTruck} from '$lib/api/trucks';
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

describe('getAllTrucks', () => {
  afterEach(() => vi.clearAllMocks());

  it('calls api.get once with page 1 when the first page is not full', async () => {
    const trucks = [makeTruck({id: 1}), makeTruck({id: 2})];
    vi.mocked(api.get).mockResolvedValue(trucks);
    const result = await getAllTrucks();
    expect(api.get).toHaveBeenCalledTimes(1);
    expect(api.get).toHaveBeenCalledWith('/trucks?per_page=100&page=1');
    expect(result.data).toEqual(trucks);
    expect(result.error).toBeNull();
  });

  it('walks every page until a short page is returned', async () => {
    const page1 = Array.from({length: 100}, (_, i) => makeTruck({id: i + 1}));
    const page2 = Array.from({length: 100}, (_, i) => makeTruck({id: i + 101}));
    const page3 = [makeTruck({id: 201})];
    vi.mocked(api.get)
      .mockResolvedValueOnce(page1)
      .mockResolvedValueOnce(page2)
      .mockResolvedValueOnce(page3);

    const result = await getAllTrucks();

    expect(api.get).toHaveBeenCalledTimes(3);
    expect(api.get).toHaveBeenNthCalledWith(1, '/trucks?per_page=100&page=1');
    expect(api.get).toHaveBeenNthCalledWith(2, '/trucks?per_page=100&page=2');
    expect(api.get).toHaveBeenNthCalledWith(3, '/trucks?per_page=100&page=3');
    expect(result.data).toHaveLength(201);
    expect(result.error).toBeNull();
  });

  it('fetches a trailing empty page when the count is an exact multiple of 100', async () => {
    const page1 = Array.from({length: 100}, (_, i) => makeTruck({id: i + 1}));
    const page2 = Array.from({length: 100}, (_, i) => makeTruck({id: i + 101}));
    const page3 = Array.from({length: 100}, (_, i) => makeTruck({id: i + 201}));
    vi.mocked(api.get)
      .mockResolvedValueOnce(page1)
      .mockResolvedValueOnce(page2)
      .mockResolvedValueOnce(page3)
      .mockResolvedValueOnce([]);

    const result = await getAllTrucks();

    expect(api.get).toHaveBeenCalledTimes(4);
    expect(api.get).toHaveBeenNthCalledWith(4, '/trucks?per_page=100&page=4');
    expect(result.data).toHaveLength(300);
    expect(result.error).toBeNull();
  });

  it('finds a truck that would be past the first page', async () => {
    const page1 = Array.from({length: 100}, (_, i) => makeTruck({id: i + 1}));
    const farTruck = makeTruck({id: 150, plateNumber: 'FAR-001'});
    vi.mocked(api.get).mockResolvedValueOnce(page1).mockResolvedValueOnce([farTruck]);

    const result = await getAllTrucks();

    expect(result.data.some((t) => t.plateNumber === 'FAR-001')).toBe(true);
  });

  it('returns an empty array when there are no trucks', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    const result = await getAllTrucks();
    expect(result.data).toEqual([]);
    expect(api.get).toHaveBeenCalledTimes(1);
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getAllTrucks();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getAllTrucks();
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
