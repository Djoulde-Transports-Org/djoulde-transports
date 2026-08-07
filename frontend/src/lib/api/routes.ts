import {api} from './client';
import type {Route} from '$lib/types/route';

type RoutesResult = {data: Route[]; error: string | null};
type RouteOriginsResult = {data: string[]; error: string | null};

export const getRoutes = async (perPage = 100, origin?: string): Promise<RoutesResult> => {
  try {
    const query = origin
      ? `per_page=${perPage}&origin=${encodeURIComponent(origin)}`
      : `per_page=${perPage}`;
    return {data: await api.get<Route[]>(`/routes?${query}`), error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

export const getRouteOrigins = async (): Promise<RouteOriginsResult> => {
  try {
    return {data: await api.get<string[]>('/routes/origins'), error: null};
  } catch (e) {
    return {data: [], error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
