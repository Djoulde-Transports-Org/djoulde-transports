import {render, waitFor, fireEvent} from '@testing-library/svelte';
import BillingList from '$lib/components/facturation/BillingList.svelte';
import {makeBillingStatement} from '../../../mocks/billing';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

describe('BillingList', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the month, number, and amounts for each statement', async () => {
    mockGet.mockResolvedValue([
      makeBillingStatement({
        number: 'S-2026-06',
        month: '2026-06-01',
        totalAmount: 5_000_000,
        totalTva: 900_000,
        grandTotal: 5_900_000,
      }),
    ]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Juin 2026')).toBeInTheDocument());
    expect(getByText('S-2026-06')).toBeInTheDocument();
    expect(getByText('5 000 000 GNF')).toBeInTheDocument();
    expect(getByText('900 000 GNF')).toBeInTheDocument();
    expect(getByText('5 900 000 GNF')).toBeInTheDocument();
  });

  it('shows the Brouillon pill with a neutral left border for a draft statement', async () => {
    mockGet.mockResolvedValue([makeBillingStatement({status: 'draft', number: 'S-DRAFT'})]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Brouillon')).toBeInTheDocument());
    const card = getByText('S-DRAFT').closest('div.rounded-lg');
    expect(card).toHaveClass('border-l-border');
  });

  it('shows the Émise pill with an orange (accent) left border for an issued statement', async () => {
    mockGet.mockResolvedValue([makeBillingStatement({status: 'issued', number: 'S-ISSUED'})]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Émise')).toBeInTheDocument());
    const card = getByText('S-ISSUED').closest('div.rounded-lg');
    expect(card).toHaveClass('border-l-accent');
  });

  it('shows the Payée pill with a green left border for a paid statement', async () => {
    mockGet.mockResolvedValue([makeBillingStatement({status: 'paid', number: 'S-PAID'})]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Payée')).toBeInTheDocument());
    const card = getByText('S-PAID').closest('div.rounded-lg');
    expect(card).toHaveClass('border-l-dt-green');
  });

  it('shows the Annulée pill with a red left border for a void statement', async () => {
    mockGet.mockResolvedValue([makeBillingStatement({status: 'void', number: 'S-VOID'})]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Annulée')).toBeInTheDocument());
    const card = getByText('S-VOID').closest('div.rounded-lg');
    expect(card).toHaveClass('border-l-dt-red');
  });

  it('renders the Toutes / Brouillon / Émises / Payées filter chips', async () => {
    mockGet.mockResolvedValue([]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Toutes')).toBeInTheDocument());
    expect(getByText('Brouillon')).toBeInTheDocument();
    expect(getByText('Émises')).toBeInTheDocument();
    expect(getByText('Payées')).toBeInTheDocument();
  });

  it('refetches with the status filter when a chip is clicked', async () => {
    mockGet.mockResolvedValue([]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
    await fireEvent.click(getByText('Payées'));
    await waitFor(() =>
      expect(mockGet).toHaveBeenLastCalledWith('/billing_statements?status=paid')
    );
  });

  it('shows the empty state when there are no statements', async () => {
    mockGet.mockResolvedValue([]);
    const {getByText} = render(BillingList);
    await waitFor(() => expect(getByText('Aucun résultat.')).toBeInTheDocument());
  });
});
