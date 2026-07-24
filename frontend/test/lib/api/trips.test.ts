import {api} from '$lib/api/client';
import {getTrips} from '$lib/api/trips';
import {makeTrip} from '../../mocks/trip';

vi.mock('$lib/api/client', () => ({api: {get: vi.fn()}}));

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
