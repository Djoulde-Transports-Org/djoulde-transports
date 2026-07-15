import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/dashboard/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (dashboard)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders DashboardStats — card labels are present', () => {
    const {getByText} = render(Page);
    expect(getByText('Camions actifs')).toBeInTheDocument();
    expect(getByText('Trajets en cours')).toBeInTheDocument();
    expect(getByText('Litres livrés')).toBeInTheDocument();
    expect(getByText('Facturation HT')).toBeInTheDocument();
  });
});
