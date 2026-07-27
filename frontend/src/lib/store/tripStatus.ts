import type {TripStatus} from '$lib/types/trip';

export const tripStatusMeta: Record<TripStatus, {label: string; classes: string}> = {
  scheduled: {label: 'Planifié', classes: 'bg-surface-2 text-dt-text-muted border-border'},
  in_progress: {label: 'En cours', classes: 'bg-accent/10 text-accent border-accent/20'},
  completed: {label: 'Terminé', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
  cancelled: {label: 'Annulé', classes: 'bg-dt-red/10 text-dt-red border-dt-red/20'},
};

const FILTER_LABEL_OVERRIDES: Partial<Record<TripStatus, string>> = {
  scheduled: 'Planifiés',
  completed: 'Terminés',
  cancelled: 'Annulés',
};

const STATUS_FILTER_ORDER: TripStatus[] = ['in_progress', 'scheduled', 'completed', 'cancelled'];

export const tripStatusFilters = [
  {key: 'status', label: 'Tous', value: ''},
  ...STATUS_FILTER_ORDER.map((status) => ({
    key: 'status',
    label: FILTER_LABEL_OVERRIDES[status] ?? tripStatusMeta[status].label,
    value: status,
  })),
];
