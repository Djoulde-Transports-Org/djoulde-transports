import {api} from './client';
import type {CreateMaintenancePayload, Maintenance} from '$lib/types/maintenance';

type MaintenanceResult = {data: Maintenance | null; error: string | null};

export const createMaintenance = async (
  payload: CreateMaintenancePayload
): Promise<MaintenanceResult> => {
  try {
    return {data: await api.post<Maintenance>('/maintenances/create', payload), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
