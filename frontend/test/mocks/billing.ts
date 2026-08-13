import type {BillingStatement} from '$lib/types/billing';
import type {BillingLineItem} from '$lib/types/billingLineItem';

export const makeBillingStatement = (
  overrides: Partial<BillingStatement> = {}
): BillingStatement => ({
  id: 1,
  number: 'S-2026-06',
  status: 'draft',
  month: '2026-06-01',
  startsOn: '2026-06-01',
  endsOn: '2026-06-30',
  issuedOn: null,
  dueOn: null,
  paidOn: null,
  totalAmount: 0,
  totalTva: 0,
  grandTotal: 0,
  ...overrides,
});

export const makeBillingLineItem = (overrides: Partial<BillingLineItem> = {}): BillingLineItem => ({
  id: 1,
  billingStatementId: 1,
  tripId: 1,
  deliveryNoteNumber: 'DN-0001',
  startedOn: '2026-06-05',
  origin: 'Conakry',
  destination: 'Kankan',
  gasolineQuantity: 0,
  dieselQuantity: 10_000,
  rate: 1_000,
  amount: 10_000_000,
  tva: 1_800_000,
  ...overrides,
});
