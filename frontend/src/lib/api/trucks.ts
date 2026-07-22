import {api} from './client';
import type {Truck} from '$lib/types/truck';

type TrucksResult = {data: Truck[]; error: string | null};
type TruckResult = {data: Truck | null; error: string | null};

export type CreateTruckPayload = {
  plate_number: string;
  vin?: string;
  make?: string;
  model: string;
  year: number;
  status?: string;
  driver_id?: number;
  last_oil_change_on?: string;
  tank: {
    plate_number: string;
    capacity: number;
    vin?: string;
    make?: string;
    model?: string;
    year?: number;
  };
  documents?: {
    truck_insurance_expires_on?: string;
    cargo_insurance_expires_on?: string;
    technical_inspection_expires_on?: string;
    operating_permit_expires_on?: string;
    truck_registration_expires_on?: string;
  };
};

export const getTrucks = async (perPage = 7): Promise<TrucksResult> => {
  try {
    return {data: await api.get<Truck[]>(`/trucks?per_page=${perPage}`), error: null};
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
