import type {BillingStatus} from '$lib/types/billing';

export const billingStatusMeta: Record<BillingStatus, {label: string; classes: string}> = {
  draft: {label: 'Brouillon', classes: 'bg-surface-2 text-dt-text-muted border-border'},
  issued: {label: 'Émise', classes: 'bg-accent/10 text-accent border-accent/20'},
  paid: {label: 'Payée', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
  void: {label: 'Annulée', classes: 'bg-dt-red/10 text-dt-red border-dt-red/20'},
};

const STATUS_FILTER_ORDER: BillingStatus[] = ['draft', 'issued', 'paid'];

const FILTER_LABEL_OVERRIDES: Partial<Record<BillingStatus, string>> = {
  draft: 'Brouillon',
  issued: 'Émises',
  paid: 'Payées',
};

export const billingStatusFilters = [
  {key: 'status', label: 'Toutes', value: ''},
  ...STATUS_FILTER_ORDER.map((status) => ({
    key: 'status',
    label: FILTER_LABEL_OVERRIDES[status] ?? billingStatusMeta[status].label,
    value: status,
  })),
];
