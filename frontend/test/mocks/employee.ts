import type {Employee} from '$lib/types/employee';

export const makeEmployee = (overrides: Partial<Employee> = {}): Employee => ({
  id: 1,
  first_name: 'Ibrahima',
  last_name: 'Bah',
  full_name: 'Ibrahima Bah',
  phone_number: null,
  role: 'driver',
  user_id: null,
  ...overrides,
});
