import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/flotte/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (flotte)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders FleetTable — column headers are present', () => {
    const {getByText} = render(Page);
    expect(getByText('Immatriculation')).toBeInTheDocument();
    expect(getByText('Modèle')).toBeInTheDocument();
    expect(getByText('Citerne')).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
    expect(getByText('Dernière vidange')).toBeInTheDocument();
  });
});
