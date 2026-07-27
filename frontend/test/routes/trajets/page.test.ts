import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/trajets/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (trajets)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders TripTable, column headers are present', () => {
    const {getByText} = render(Page);
    expect(getByText('N° trajet')).toBeInTheDocument();
    expect(getByText('Camion/Citerne')).toBeInTheDocument();
    expect(getByText('Route')).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
  });
});
