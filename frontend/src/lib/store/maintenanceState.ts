import type {MaintenanceState} from '$lib/types/maintenance';

export const maintenanceStateMeta: Record<MaintenanceState, {label: string; classes: string}> = {
  started: {label: 'En cours', classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20'},
  completed: {label: 'Terminé', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
};

const STATE_FILTER_ORDER: MaintenanceState[] = ['started', 'completed'];

const FILTER_LABEL_OVERRIDES: Partial<Record<MaintenanceState, string>> = {
  started: 'En cours',
  completed: 'Terminés',
};

export const maintenanceStateFilters = [
  {key: 'state', label: 'Tous', value: ''},
  ...STATE_FILTER_ORDER.map((state) => ({
    key: 'state',
    label: FILTER_LABEL_OVERRIDES[state] ?? maintenanceStateMeta[state].label,
    value: state,
  })),
];
