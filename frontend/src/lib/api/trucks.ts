import {api} from './client';
import type {Truck, CreateTruckPayload} from '$lib/types/truck';

type TrucksResult = {data: Truck[]; error: string | null};
type TruckResult = {data: Truck | null; error: string | null};

export const getTrucks = async (perPage = 7): Promise<TrucksResult> => {
  try {
    return {data: await api.get<Truck[]>(`/trucks?per_page=${perPage}`), error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

export const getAllTrucks = async (): Promise<TrucksResult> => {
  const perPage = 100;
  try {
    let all: Truck[] = [];
    let page = 1;
    for (;;) {
      const batch = await api.get<Truck[]>(`/trucks?per_page=${perPage}&page=${page}`);
      all = all.concat(batch);
      if (batch.length < perPage) break;
      page += 1;
    }
    return {data: all, error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

export const createTruck = async (payload: CreateTruckPayload): Promise<TruckResult> => {
  try {
    return {data: await api.post<Truck>('/trucks/create', payload), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
