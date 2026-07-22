import type {Truck, TruckTank} from '$lib/types/truck';

export const formatTruckModel = (truck: Truck): string => {
  const makeModel = [truck.make, truck.model].filter(Boolean).join(' ');
  if (!makeModel && !truck.year) return '—';
  return [makeModel, truck.year].filter(Boolean).join(' · ');
};

export const formatTankSummary = (tank: TruckTank | null): string =>
  tank ? `${tank.plate_number} · ${tank.capacity.toLocaleString('fr-FR')} L` : '—';

export type TruckDocumentRow = {label: string; daysRemaining: number | null};

export const truckDocumentRows = (truck: Truck): TruckDocumentRow[] => [
  {label: 'Ass. camion', daysRemaining: truck.truck_insurance_days_remaining},
  {label: 'Ass. produit', daysRemaining: truck.cargo_insurance_days_remaining},
  {label: 'Visite tech.', daysRemaining: truck.technical_inspection_days_remaining},
  {label: 'Carte de Transport', daysRemaining: truck.operating_permit_days_remaining},
  {label: 'Carte grise', daysRemaining: truck.truck_registration_days_remaining},
  {label: 'Baremage', daysRemaining: truck.tank?.conformity_certificate_days_remaining ?? null},
];
