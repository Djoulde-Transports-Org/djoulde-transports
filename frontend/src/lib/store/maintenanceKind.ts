import type {MaintenanceKind} from '$lib/types/maintenance';

export const maintenanceKindLabels: Record<MaintenanceKind, string> = {
  routine: 'Entretien courant',
  repair: 'Réparation',
  inspection: 'Inspection',
  oil_change: 'Vidange',
};
