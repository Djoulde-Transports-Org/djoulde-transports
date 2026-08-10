import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/maintenance/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (maintenance)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders MaintenanceList, filter chips are present', () => {
    const {getByText} = render(Page);
    expect(getByText('Tous')).toBeInTheDocument();
    expect(getByText('En cours')).toBeInTheDocument();
    expect(getByText('Terminés')).toBeInTheDocument();
  });
});
