import {api, ApiRequestError} from '$lib/api/client';
import {getTrips, createTrip} from '$lib/api/trips';
import type {CreateTripPayload} from '$lib/types/trip';
import {makeTrip} from '../../mocks/trip';

vi.mock('$lib/api/client', async () => {
  const actual = await vi.importActual<typeof import('$lib/api/client')>('$lib/api/client');
  return {...actual, api: {get: vi.fn(), post: vi.fn()}};
});

describe('getTrips', () => {
  afterEach(() => vi.clearAllMocks());

  it('calls api.get with /trips and the default limit of 6', async () => {
    vi.mocked(api.get).mockResolvedValue({items: [], nextCursor: null, hasMore: false});
    await getTrips();
    expect(api.get).toHaveBeenCalledWith('/trips?limit=6');
  });

  it('calls api.get with the supplied limit', async () => {
    vi.mocked(api.get).mockResolvedValue({items: [], nextCursor: null, hasMore: false});
    await getTrips(10);
    expect(api.get).toHaveBeenCalledWith('/trips?limit=10');
  });

  it('returns the items and null error on success', async () => {
    const trips = [makeTrip()];
    vi.mocked(api.get).mockResolvedValue({items: trips, nextCursor: null, hasMore: false});
    const result = await getTrips();
    expect(result.data).toEqual(trips);
    expect(result.error).toBeNull();
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getTrips();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getTrips();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Une erreur est survenue.');
  });
});

describe('createTrip', () => {
  afterEach(() => vi.clearAllMocks());

  const payload: CreateTripPayload = {
    truckId: 1,
    routeId: 1,
    deliveryNote: {number: 'DN-001', gasolineQuantity: 1_000, dieselQuantity: 500},
  };

  it('calls api.post with /trips/create and the payload', async () => {
    vi.mocked(api.post).mockResolvedValue(makeTrip());
    await createTrip(payload);
    expect(api.post).toHaveBeenCalledWith('/trips/create', payload);
  });

  it('returns data and null error on success', async () => {
    const trip = makeTrip();
    vi.mocked(api.post).mockResolvedValue(trip);
    const result = await createTrip(payload);
    expect(result.data).toEqual(trip);
    expect(result.error).toBeNull();
  });

  it('returns the error message and null data when the API throws a plain Error', async () => {
    vi.mocked(api.post).mockRejectedValue(new Error('Validation failed.'));
    const result = await createTrip(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Validation failed.');
  });

  it('joins ApiRequestError details into a readable message when present', async () => {
    vi.mocked(api.post).mockRejectedValue(
      new ApiRequestError('validation_failed', 'Validation failed.', {
        base: ['loaded quantity (1100 L) is less than the tank capacity (1500 L)'],
      })
    );
    const result = await createTrip(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('loaded quantity (1100 L) is less than the tank capacity (1500 L)');
  });

  it('joins multiple detail messages across fields', async () => {
    vi.mocked(api.post).mockRejectedValue(
      new ApiRequestError('validation_failed', 'Validation failed.', {
        base: ['must have a non-zero quantity of gasoline or diesel'],
        number: ['has already been taken'],
      })
    );
    const result = await createTrip(payload);
    expect(result.error).toBe(
      'must have a non-zero quantity of gasoline or diesel has already been taken'
    );
  });

  it('falls back to the message when details is empty', async () => {
    vi.mocked(api.post).mockRejectedValue(
      new ApiRequestError('validation_failed', 'Validation failed.', {})
    );
    const result = await createTrip(payload);
    expect(result.error).toBe('Validation failed.');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.post).mockRejectedValue('oops');
    const result = await createTrip(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
