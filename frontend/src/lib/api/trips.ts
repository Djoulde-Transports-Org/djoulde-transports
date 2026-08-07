import {api, ApiRequestError} from './client';
import type {CreateTripPayload, Trip} from '$lib/types/trip';

type TripsResponse = {items: Trip[]; nextCursor: number | null; hasMore: boolean};

type TripsResult = {data: Trip[]; error: string | null};
type TripResult = {data: Trip | null; error: string | null};

export const getTrips = async (limit = 6): Promise<TripsResult> => {
  try {
    const res = await api.get<TripsResponse>(`/trips?limit=${limit}`);
    return {data: res.items, error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

const errorMessage = (e: unknown): string => {
  if (e instanceof ApiRequestError && e.details && typeof e.details === 'object') {
    const messages = Object.values(e.details as Record<string, string[]>).flat();
    if (messages.length) return messages.join(' ');
  }
  return e instanceof Error ? e.message : 'Une erreur est survenue.';
};

export const createTrip = async (payload: CreateTripPayload): Promise<TripResult> => {
  try {
    return {data: await api.post<Trip>('/trips/create', payload), error: null};
  } catch (e) {
    return {data: null, error: errorMessage(e)};
  }
};
