import type {Truck, TruckDriver} from './truck';

export type TripStatus = 'scheduled' | 'in_progress' | 'completed' | 'cancelled';

export type TripRoute = {
  id: number;
  origin: string;
  destination: string;
  rate: number;
};

export type TripDeliveryNote = {
  id: number;
  trip_id: number;
  number: string;
  delivered_on: string | null;
  gasoline_quantity: number;
  diesel_quantity: number;
  total_quantity: number;
  missing_quantity: number | null;
  product: string;
};

export type TripBillingStatement = {
  id: number;
  number: string;
  status: string;
  month: string;
  starts_on: string;
  ends_on: string;
  issued_on: string | null;
  due_on: string | null;
  total_amount: number;
  total_tva: number;
  grand_total: number;
};

export type Trip = {
  id: number;
  status: TripStatus;
  cargo_description: string | null;
  distance_km: number | null;
  scheduled_start_at: string | null;
  scheduled_end_at: string | null;
  actual_start_at: string | null;
  actual_end_at: string | null;
  truck: Truck;
  driver: TruckDriver | null;
  route: TripRoute;
  delivery_note: TripDeliveryNote | null;
  billing_statement: TripBillingStatement | null;
};
