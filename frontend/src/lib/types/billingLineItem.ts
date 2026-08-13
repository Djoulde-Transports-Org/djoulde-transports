export type BillingLineItem = {
  id: number;
  billingStatementId: number;
  tripId: number;
  deliveryNoteNumber: string | null;
  startedOn: string | null;
  origin: string;
  destination: string;
  gasolineQuantity: number;
  dieselQuantity: number;
  rate: number;
  amount: number;
  tva: number;
};
