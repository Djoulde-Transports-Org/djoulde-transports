import type {Employee} from '$lib/types/employee';

export const makeEmployee = (overrides: Partial<Employee> = {}): Employee => ({
  id: 1,
  firstName: 'Ibrahima',
  lastName: 'Bah',
  fullName: 'Ibrahima Bah',
  phoneNumber: null,
  role: 'driver',
  userId: null,
  ...overrides,
});
