import {api} from '$lib/api/client';
import {getMaintenanceKinds} from '$lib/api/maintenanceKinds';

vi.mock('$lib/api/client', () => ({api: {get: vi.fn()}}));

describe('getMaintenanceKinds', () => {
  afterEach(() => vi.clearAllMocks());

  it('calls api.get with /maintenance_kinds', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getMaintenanceKinds();
    expect(api.get).toHaveBeenCalledWith('/maintenance_kinds');
  });

  it('returns data and null error on success', async () => {
    const kinds = [{id: 1, name: 'repair'}];
    vi.mocked(api.get).mockResolvedValue(kinds);
    const result = await getMaintenanceKinds();
    expect(result.data).toEqual(kinds);
    expect(result.error).toBeNull();
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getMaintenanceKinds();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getMaintenanceKinds();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
