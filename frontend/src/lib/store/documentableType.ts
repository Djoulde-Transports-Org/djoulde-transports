import type {DocumentableType} from '$lib/types/document';

export const documentableTypeLabels: Record<DocumentableType, string> = {
  Truck: 'Camion',
  Tank: 'Citerne',
  Trip: 'Trajet',
  Maintenance: 'Maintenance',
  BillingStatement: 'Facturation',
  Employee: 'Employé',
};

export const documentableTypeLabel = (type: DocumentableType): string =>
  documentableTypeLabels[type] ?? type;

const ENTITY_FILTER_ORDER: DocumentableType[] = [
  'Truck',
  'Tank',
  'Trip',
  'Maintenance',
  'Employee',
  'BillingStatement',
];

const FILTER_LABEL_OVERRIDES: Partial<Record<DocumentableType, string>> = {
  Truck: 'Camions',
  Tank: 'Citernes',
  Trip: 'Trajets',
  Employee: 'Employés',
  BillingStatement: 'Facturations',
};

export const documentEntityFilters = [
  {key: 'documentable_type', label: 'Tous', value: ''},
  ...ENTITY_FILTER_ORDER.map((type) => ({
    key: 'documentable_type',
    label: FILTER_LABEL_OVERRIDES[type] ?? documentableTypeLabels[type],
    value: type,
  })),
];
