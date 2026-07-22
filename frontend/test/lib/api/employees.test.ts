import {api} from '$lib/api/client';
import {getEmployees} from '$lib/api/employees';
import {makeEmployee} from '../../mocks/employee';

vi.mock('$lib/api/client', () => ({api: {get: vi.fn()}}));

describe('getEmployees', () => {
  afterEach(() => vi.clearAllMocks());

  it('calls api.get with /employees and the default role of driver', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getEmployees();
    expect(api.get).toHaveBeenCalledWith('/employees?role=driver');
  });

  it('calls api.get with the supplied role', async () => {
    vi.mocked(api.get).mockResolvedValue([]);
    await getEmployees('mechanic');
    expect(api.get).toHaveBeenCalledWith('/employees?role=mechanic');
  });

  it('returns data and null error on success', async () => {
    const employees = [makeEmployee()];
    vi.mocked(api.get).mockResolvedValue(employees);
    const result = await getEmployees();
    expect(result.data).toEqual(employees);
    expect(result.error).toBeNull();
  });

  it('returns the error message and empty data when the API throws', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'));
    const result = await getEmployees();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Network error');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.get).mockRejectedValue('oops');
    const result = await getEmployees();
    expect(result.data).toEqual([]);
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
