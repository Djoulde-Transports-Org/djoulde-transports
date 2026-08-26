import {api} from './client';
import type {TruckTank} from '$lib/types/truck';

type TanksResult = {data: TruckTank[]; error: string | null};

export const getAllTanks = async (): Promise<TanksResult> => {
  const perPage = 100;
  try {
    let all: TruckTank[] = [];
    let page = 1;
    for (;;) {
      const batch = await api.get<TruckTank[]>(`/tanks?per_page=${perPage}&page=${page}`);
      all = all.concat(batch);
      if (batch.length < perPage) break;
      page += 1;
    }
    return {data: all, error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
