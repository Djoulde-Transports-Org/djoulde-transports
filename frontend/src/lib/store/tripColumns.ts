import type {TripColumn} from '$lib/types/tripColumns';

export const tripColumns: TripColumn[] = [
  {key: 'id', label: 'N° trajet', cell: 'number'},
  {key: 'truck', label: 'Camion/Citerne', cell: 'truckTank'},
  {key: 'route', label: 'Route', cell: 'route'},
  {key: 'driver', label: 'Chauffeur', cell: 'driver'},
  {key: 'gasoilLiters', label: 'Gasoil (L)', cell: 'gasoil'},
  {key: 'essenceLiters', label: 'Essence (L)', cell: 'essence'},
  {key: 'pretaxAmount', label: 'Montant HT', cell: 'pretaxAmount'},
  {key: 'status', label: 'Statut', cell: 'status'},
  {key: 'scheduledStartAt', label: 'Départ', cell: 'departure'},
];
