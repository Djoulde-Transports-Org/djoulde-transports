import {api} from './client';
import type {Employee, EmployeePayload} from '$lib/types/employee';

type EmployeesResult = {data: Employee[]; error: string | null};
type EmployeeResult = {data: Employee | null; error: string | null};

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

export const createEmployee = async (payload: EmployeePayload): Promise<EmployeeResult> => {
  try {
    return {data: await api.post<Employee>('/employees/create', payload), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

export const updateEmployee = async (
  id: number,
  payload: EmployeePayload
): Promise<EmployeeResult> => {
  try {
    return {data: await api.patch<Employee>(`/employees/${id}/update`, payload), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
