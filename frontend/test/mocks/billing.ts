import type {BillingStatement} from '$lib/types/billing';

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
  totalAmount: 0,
  totalTva: 0,
  grandTotal: 0,
  ...overrides,
});
