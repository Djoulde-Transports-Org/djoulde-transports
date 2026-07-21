import {api} from './client';
import type {Trip} from '$lib/types/trip';

type TripsResponse = {items: Trip[]; next_cursor: number | null; has_more: boolean};

type TripsResult = {data: Trip[]; error: string | null};

export const getTrips = async (limit = 6): Promise<TripsResult> => {
  try {
    const res = await api.get<TripsResponse>(`/trips?limit=${limit}`);
    return {data: res.items, error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
