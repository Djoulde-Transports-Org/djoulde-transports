import type {BillingLineItemColumn} from '$lib/types/billingLineItemColumns';

export const billingLineItemColumns: BillingLineItemColumn[] = [
  {key: 'startedOn', label: 'Date', cell: 'date'},
  {key: 'deliveryNoteNumber', label: 'N° bon de livraison', cell: 'deliveryNoteNumber'},
  {key: 'route', label: 'Route', cell: 'route'},
  {key: 'dieselQuantity', label: 'Gasoil (L)', cell: 'gasoil'},
  {key: 'gasolineQuantity', label: 'Essence (L)', cell: 'essence'},
  {key: 'rate', label: 'Tarif', cell: 'rate'},
  {key: 'amount', label: 'Montant HT', cell: 'amount'},
  {key: 'tva', label: 'TVA', cell: 'tva'},
];
