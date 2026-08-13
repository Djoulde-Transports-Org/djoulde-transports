export type BillingStatus = 'draft' | 'issued' | 'paid' | 'void';

export type BillingStatement = {
  id: number;
  number: string;
  status: BillingStatus;
  month: string;
  startsOn: string;
  endsOn: string;
  issuedOn: string | null;
  dueOn: string | null;
  paidOn: string | null;
  totalAmount: number;
  totalTva: number;
  grandTotal: number;
};
