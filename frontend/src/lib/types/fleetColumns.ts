export type FleetColumnCell =
  | 'plate'
  | 'model'
  | 'citerne'
  | 'status'
  | 'oilChange'
  | 'truckInsurance'
  | 'cargoInsurance'
  | 'technicalInspection'
  | 'operatingPermit'
  | 'truckRegistration'
  | 'conformityCertificate';

export type FleetColumn = {
  key: string;
  label: string;
  cell: FleetColumnCell;
};
