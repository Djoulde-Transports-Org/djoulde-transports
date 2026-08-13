import {render, waitFor} from '@testing-library/svelte';
import BillingStatementDetail from '$lib/components/facturation/BillingStatementDetail.svelte';
import {makeBillingStatement, makeBillingLineItem} from '../../../mocks/billing';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (route: string) => route}));

const withDetailOptions =
  (statement: unknown, lineItems: unknown[]) =>
  (url: string): Promise<unknown> => {
    if (url.startsWith('/billing_statements/')) return Promise.resolve(statement);
    if (url.startsWith('/billing_line_items')) return Promise.resolve(lineItems);
    return Promise.resolve([]);
  };

describe('BillingStatementDetail', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders a back link to the facturation list', async () => {
    mockGet.mockImplementation(withDetailOptions(makeBillingStatement(), []));
    const {getByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getByText('Retour à la facturation')).toBeInTheDocument());
  });

  it('renders the month, number, status, and totals for the statement', async () => {
    mockGet.mockImplementation(
      withDetailOptions(
        makeBillingStatement({
          number: 'S-2026-06',
          month: '2026-06-01',
          status: 'issued',
          totalAmount: 5_000_000,
          totalTva: 900_000,
          grandTotal: 5_900_000,
        }),
        []
      )
    );
    const {getByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getByText('Juin 2026')).toBeInTheDocument());
    expect(getByText('S-2026-06')).toBeInTheDocument();
    expect(getByText('Émise')).toBeInTheDocument();
    expect(getByText('5 000 000 GNF')).toBeInTheDocument();
    expect(getByText('900 000 GNF')).toBeInTheDocument();
    expect(getByText('5 900 000 GNF')).toBeInTheDocument();
  });

  it('fetches line items filtered by the statement id', async () => {
    mockGet.mockImplementation(withDetailOptions(makeBillingStatement({id: 42}), []));
    render(BillingStatementDetail, {props: {id: '42'}});
    await waitFor(() =>
      expect(mockGet).toHaveBeenCalledWith('/billing_line_items?billing_statement_id=42')
    );
  });

  it('renders one row per trip with route, quantities, and amounts', async () => {
    mockGet.mockImplementation(
      withDetailOptions(makeBillingStatement(), [
        makeBillingLineItem({
          deliveryNoteNumber: 'DN-0042',
          origin: 'Conakry',
          destination: 'Kankan',
          dieselQuantity: 12_000,
          gasolineQuantity: 0,
          amount: 15_000_000,
        }),
      ])
    );
    const {getByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getByText('DN-0042')).toBeInTheDocument());
    expect(getByText('Conakry → Kankan')).toBeInTheDocument();
    expect(getByText('12 000')).toBeInTheDocument();
    expect(getByText('15 000 000')).toBeInTheDocument();
  });

  it('falls back to a dash when a line item has no delivery note number', async () => {
    mockGet.mockImplementation(
      withDetailOptions(makeBillingStatement(), [makeBillingLineItem({deliveryNoteNumber: null})])
    );
    const {getAllByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
  });

  it('shows the payment date for a paid statement', async () => {
    mockGet.mockImplementation(
      withDetailOptions(makeBillingStatement({status: 'paid', paidOn: '2026-07-04'}), [])
    );
    const {getByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getByText('Payée le 04/07/2026')).toBeInTheDocument());
  });

  it('does not show a payment date for a non-paid statement', async () => {
    mockGet.mockImplementation(withDetailOptions(makeBillingStatement({status: 'draft'}), []));
    const {getByText, queryByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getByText('Brouillon')).toBeInTheDocument());
    expect(queryByText(/Payée le/)).not.toBeInTheDocument();
  });

  it('shows the empty state when the statement has no trips', async () => {
    mockGet.mockImplementation(withDetailOptions(makeBillingStatement(), []));
    const {getByText} = render(BillingStatementDetail, {props: {id: '1'}});
    await waitFor(() => expect(getByText('Aucun résultat.')).toBeInTheDocument());
  });

  it('shows an error message when the statement cannot be loaded', async () => {
    mockGet.mockRejectedValue(new Error('Facture introuvable.'));
    const {getByText} = render(BillingStatementDetail, {props: {id: '999'}});
    await waitFor(() => expect(getByText('Facture introuvable.')).toBeInTheDocument());
  });
});
