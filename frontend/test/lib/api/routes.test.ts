import {api} from '$lib/api/client';
import {getRoutes, getRouteOrigins} from '$lib/api/routes';

vi.mock('$lib/api/client', () => ({api: {get: vi.fn()}}));

describe('getRoutes', () => {
  afterEach(() => vi.clearAllMocks());

  const ROUTES = [{id: 1, origin: 'Conakry', destination: 'Labe', rate: 1500}];

  it('calls api.get with /routes and the default perPage of 100', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getRoutes();
    expect(api.get).toHaveBeenCalledWith('/routes?per_page=100');
  });

  it('calls api.get with the supplied perPage', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getRoutes(10);
    expect(api.get).toHaveBeenCalledWith('/routes?per_page=10');
  });

  it('calls api.get with the origin filter when supplied', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getRoutes(100, 'Conakry');
    expect(api.get).toHaveBeenCalledWith('/routes?per_page=100&origin=Conakry');
  });

  it('url-encodes the origin filter', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getRoutes(100, 'Saint-Louis / Nord');
    expect(api.get).toHaveBeenCalledWith('/routes?per_page=100&origin=Saint-Louis%20%2F%20Nord');
  });

  it('returns data and null error on success', async () => {
    vi.mocked(api.get).mockResolvedValue(ROUTES);
    const result = await getRoutes();
    expect(result.data).toEqual(ROUTES);
    expect(result.error).toBeNull();
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getRoutes();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getRoutes();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Une erreur est survenue.');
  });
});

describe('getRouteOrigins', () => {
  afterEach(() => vi.clearAllMocks());

  it('calls api.get with /routes/origins', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getRouteOrigins();
    expect(api.get).toHaveBeenCalledWith('/routes/origins');
  });

  it('returns data and null error on success', async () => {
    const origins = ['Conakry', 'Kankan'];
    vi.mocked(api.get).mockResolvedValue(origins);
    const result = await getRouteOrigins();
    expect(result.data).toEqual(origins);
    expect(result.error).toBeNull();
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getRouteOrigins();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getRouteOrigins();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
