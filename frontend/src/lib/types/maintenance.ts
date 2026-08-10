export type MaintenanceState = 'started' | 'completed';

export type MaintenanceKind = 'routine' | 'repair' | 'inspection' | 'oil_change';

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
  kind: MaintenanceKind;
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
