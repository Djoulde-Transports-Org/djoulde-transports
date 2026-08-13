export type MaintenanceState = 'started' | 'completed';

export type MaintenanceTruck = {
  id: number;
  plateNumber: string;
};

export type MaintenanceTechnician = {
  id: number;
  name: string;
};

export type Maintenance = {
  id: number;
  truckId: number;
  performedById: number | null;
  kind: string;
  state: MaintenanceState;
  performedOn: string;
  cost: number | null;
  odometerKm: number | null;
  estimatedDuration: number | null;
  actualDuration: number | null;
  duration: number | null;
  description: string | null;
  truck: MaintenanceTruck;
  technician: MaintenanceTechnician | null;
};

export type CreateMaintenancePayload = {
  truckId: number;
  performedOn: string;
  kind?: string;
  performedById?: number;
  estimatedDuration?: number;
  parts?: {name: string; price?: number}[];
};

export type NewMaintenanceValues = {
  truckId: string;
  kind: string;
  performedById: string;
  performedOn: string;
  estimatedDuration: string;
  estimatedCost: string;
};
