import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/employes/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (employes)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders EmployeeTable, column headers are present', () => {
    const {getByText} = render(Page);
    expect(getByText('Nom')).toBeInTheDocument();
    expect(getByText('Rôle')).toBeInTheDocument();
    expect(getByText('Téléphone')).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
  });
});
