import {api} from './client';
import type {Employee} from '$lib/types/employee';

type EmployeesResult = {data: Employee[]; error: string | null};

export const getEmployees = async (role = 'driver'): Promise<EmployeesResult> => {
  try {
    return {
      data: await api.get<Employee[]>(`/employees?role=${encodeURIComponent(role)}`),
      error: null,
    };
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
