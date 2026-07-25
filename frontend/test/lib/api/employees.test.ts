import {api} from '$lib/api/client';
import {getEmployees, createEmployee, updateEmployee} from '$lib/api/employees';
import type {EmployeePayload} from '$lib/types/employee';
import {makeEmployee} from '../../mocks/employee';

vi.mock('$lib/api/client', () => ({api: {get: vi.fn(), post: vi.fn(), patch: vi.fn()}}));

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

describe('createEmployee', () => {
  afterEach(() => vi.clearAllMocks());

  const payload: EmployeePayload = {
    firstName: 'Mamadou',
    lastName: 'Diallo',
    role: 'driver',
    status: 'active',
    truckId: null,
  };

  it('calls api.post with /employees/create and the payload', async () => {
    vi.mocked(api.post).mockResolvedValue(makeEmployee());
    await createEmployee(payload);
    expect(api.post).toHaveBeenCalledWith('/employees/create', payload);
  });

  it('returns data and null error on success', async () => {
    const employee = makeEmployee();
    vi.mocked(api.post).mockResolvedValue(employee);
    const result = await createEmployee(payload);
    expect(result.data).toEqual(employee);
    expect(result.error).toBeNull();
  });

  it('returns the error message and null data when the API throws', async () => {
    vi.mocked(api.post).mockRejectedValue(new Error('Validation failed'));
    const result = await createEmployee(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Validation failed');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.post).mockRejectedValue('oops');
    const result = await createEmployee(payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Une erreur est survenue.');
  });
});

describe('updateEmployee', () => {
  afterEach(() => vi.clearAllMocks());

  const payload: EmployeePayload = {lastName: 'Barry'};

  it('calls api.patch with /employees/:id/update and the payload', async () => {
    vi.mocked(api.patch).mockResolvedValue(makeEmployee());
    await updateEmployee(7, payload);
    expect(api.patch).toHaveBeenCalledWith('/employees/7/update', payload);
  });

  it('returns data and null error on success', async () => {
    const employee = makeEmployee({lastName: 'Barry'});
    vi.mocked(api.patch).mockResolvedValue(employee);
    const result = await updateEmployee(7, payload);
    expect(result.data).toEqual(employee);
    expect(result.error).toBeNull();
  });

  it('returns the error message and null data when the API throws', async () => {
    vi.mocked(api.patch).mockRejectedValue(new Error('Not found'));
    const result = await updateEmployee(7, payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Not found');
  });

  it('returns a fallback message for non-Error throws', async () => {
    vi.mocked(api.patch).mockRejectedValue('oops');
    const result = await updateEmployee(7, payload);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Une erreur est survenue.');
  });
});
