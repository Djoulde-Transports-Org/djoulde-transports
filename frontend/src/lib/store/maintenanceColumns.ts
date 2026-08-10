import type {MaintenanceColumn} from '$lib/types/maintenanceColumns';

export const maintenanceColumns: MaintenanceColumn[] = [
  {key: 'truck', label: 'Camion', cell: 'truck'},
  {key: 'kind', label: 'Type', cell: 'kind'},
  {key: 'description', label: 'Description', cell: 'description'},
  {key: 'technician', label: 'Technicien', cell: 'technician'},
  {key: 'performedOn', label: 'Date', cell: 'date'},
  {key: 'duration', label: 'Durée (h)', cell: 'duration'},
  {key: 'cost', label: 'Coût pièces', cell: 'cost'},
  {key: 'state', label: 'Statut', cell: 'status'},
];
