import type {TruckStatus} from '$lib/types/truck';

export const truckStatusMeta: Record<TruckStatus, {label: string; classes: string}> = {
  on_trip: {label: 'En route', classes: 'bg-accent/10 text-accent border-accent/20'},
  in_maintenance: {
    label: 'Maintenance',
    classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20',
  },
  ready: {label: 'Prêt', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
};

const FILTER_LABEL_OVERRIDES: Partial<Record<TruckStatus, string>> = {
  ready: 'Prêts',
};

export const truckStatusFilters = [
  {key: 'status', label: 'Tous', value: ''},
  ...(Object.keys(truckStatusMeta) as TruckStatus[]).map((status) => ({
    key: 'status',
    label: FILTER_LABEL_OVERRIDES[status] ?? truckStatusMeta[status].label,
    value: status,
  })),
];
