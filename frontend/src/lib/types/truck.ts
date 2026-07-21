export type TruckStatus = 'ready' | 'on_trip' | 'in_maintenance';

export type TruckDriver = {
  id: number;
  first_name: string;
  last_name: string;
  full_name: string;
  phone_number: string | null;
  role: string;
  user_id: number | null;
};

export type TruckTank = {
  id: number;
  truck_id: number;
  plate_number: string;
  vin: string | null;
  make: string | null;
  model: string | null;
  year: number | null;
  capacity: number;
  status: string;
};

export type Truck = {
  id: number;
  plate_number: string;
  vin: string | null;
  make: string | null;
  model: string | null;
  year: number | null;
  status: TruckStatus;
  created_by_id: number;
  tank: TruckTank | null;
  driver: TruckDriver | null;
  last_oil_change_on: string | null;
  truck_insurance_expires_on: string | null;
  truck_insurance_days_remaining: number | null;
  cargo_insurance_expires_on: string | null;
  cargo_insurance_days_remaining: number | null;
  technical_inspection_expires_on: string | null;
  technical_inspection_days_remaining: number | null;
  operating_permit_expires_on: string | null;
  operating_permit_days_remaining: number | null;
  trips_count: number;
  total_km: number;
  total_liters_delivered: number;
};
