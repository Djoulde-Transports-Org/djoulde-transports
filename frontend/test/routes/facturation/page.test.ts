import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/facturation/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (facturation)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders BillingList, filter chips are present', () => {
    const {getByText} = render(Page);
    expect(getByText('Toutes')).toBeInTheDocument();
    expect(getByText('Brouillon')).toBeInTheDocument();
    expect(getByText('Émises')).toBeInTheDocument();
    expect(getByText('Payées')).toBeInTheDocument();
  });
});
