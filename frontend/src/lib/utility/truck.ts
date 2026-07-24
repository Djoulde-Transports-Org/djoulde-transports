import type {Truck, TruckTank} from '$lib/types/truck';

export const formatTruckModel = (truck: Truck): string => {
  const makeModel = [truck.make, truck.model].filter(Boolean).join(' ');
  if (!makeModel && !truck.year) return '—';
  return [makeModel, truck.year].filter(Boolean).join(' · ');
};

export const formatTankSummary = (tank: TruckTank | null): string =>
  tank ? `${tank.plateNumber} · ${tank.capacity.toLocaleString('fr-FR')} L` : '—';

export type TruckDocumentRow = {label: string; daysRemaining: number | null};

export const truckDocumentRows = (truck: Truck): TruckDocumentRow[] => [
  {label: 'Ass. camion', daysRemaining: truck.truckInsuranceDaysRemaining},
  {label: 'Ass. produit', daysRemaining: truck.cargoInsuranceDaysRemaining},
  {label: 'Visite tech.', daysRemaining: truck.technicalInspectionDaysRemaining},
  {label: 'Carte de Transport', daysRemaining: truck.operatingPermitDaysRemaining},
  {label: 'Carte grise', daysRemaining: truck.truckRegistrationDaysRemaining},
  {label: 'Baremage', daysRemaining: truck.tank?.conformityCertificateDaysRemaining ?? null},
];
