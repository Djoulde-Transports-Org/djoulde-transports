export type TripColumnCell =
  | 'number'
  | 'truckTank'
  | 'route'
  | 'driver'
  | 'gasoil'
  | 'essence'
  | 'pretaxAmount'
  | 'status'
  | 'departure';

export type TripColumn = {
  key: string;
  label: string;
  cell: TripColumnCell;
};
