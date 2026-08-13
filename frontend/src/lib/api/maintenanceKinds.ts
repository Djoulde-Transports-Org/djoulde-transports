import {api} from './client';
import type {MaintenanceKindOption} from '$lib/types/maintenanceKind';

type MaintenanceKindsResult = {data: MaintenanceKindOption[]; error: string | null};

export const getMaintenanceKinds = async (): Promise<MaintenanceKindsResult> => {
  try {
    return {data: await api.get<MaintenanceKindOption[]>('/maintenance_kinds'), error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
