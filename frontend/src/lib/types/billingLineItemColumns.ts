export type BillingLineItemColumnCell =
  | 'date'
  | 'deliveryNoteNumber'
  | 'route'
  | 'gasoil'
  | 'essence'
  | 'rate'
  | 'amount'
  | 'tva';

export type BillingLineItemColumn = {
  key: string;
  label: string;
  cell: BillingLineItemColumnCell;
};
