export type MaintenanceColumnCell =
  | 'truck'
  | 'kind'
  | 'description'
  | 'technician'
  | 'date'
  | 'duration'
  | 'cost'
  | 'status';

export type MaintenanceColumn = {
  key: string;
  label: string;
  cell: MaintenanceColumnCell;
};
