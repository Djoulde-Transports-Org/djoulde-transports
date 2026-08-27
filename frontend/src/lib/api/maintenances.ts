import {api} from './client';
import type {CreateMaintenancePayload, Maintenance} from '$lib/types/maintenance';

type MaintenancesResponse = {items: Maintenance[]; nextCursor: number | null; hasMore: boolean};
type MaintenancesResult = {data: Maintenance[]; error: string | null};
type MaintenanceResult = {data: Maintenance | null; error: string | null};

export const getMaintenances = async (limit = 100): Promise<MaintenancesResult> => {
  try {
    const res = await api.get<MaintenancesResponse>(`/maintenances?limit=${limit}`);
    return {data: res.items, error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

export const createMaintenance = async (
  payload: CreateMaintenancePayload
): Promise<MaintenanceResult> => {
  try {
    return {data: await api.post<Maintenance>('/maintenances/create', payload), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
