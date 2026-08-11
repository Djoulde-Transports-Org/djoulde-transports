import {api} from '$lib/api/client';
import {createMaintenance} from '$lib/api/maintenances';
import type {CreateMaintenancePayload} from '$lib/types/maintenance';
import {makeMaintenance} from '../../mocks/maintenance';

vi.mock('$lib/api/client', () => ({api: {post: vi.fn()}}));

describe('createMaintenance', () => {
  afterEach(() => vi.clearAllMocks());

  const payload: CreateMaintenancePayload = {
    truckId: 1,
    performedOn: '2026-06-25',
    kind: 'repair',
  };

  it('calls api.post with /maintenances/create and the payload', async () => {
    vi.mocked(api.post).mockResolvedValue(makeMaintenance());
    await createMaintenance(payload);
    expect(api.post).toHaveBeenCalledWith('/maintenances/create', payload);
  });

  it('returns data and null error on success', async () => {
    const maintenance = makeMaintenance();
    vi.mocked(api.post).mockResolvedValue(maintenance);
    const result = await createMaintenance(payload);
    expect(result.data).toEqual(maintenance);
    expect(result.error).toBeNull();
  });

  it('returns the error message and null data when the API throws', async () => {
    vi.mocked(api.post).mockRejectedValue(new Error('Validation failed'));
    const result = await createMaintenance(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Validation failed');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.post).mockRejectedValue('oops');
    const result = await createMaintenance(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
