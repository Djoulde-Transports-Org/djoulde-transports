import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/documents/+page.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

describe('+page (documents)', () => {
  beforeEach(() => {
    mockGet.mockReturnValue(new Promise(() => {}));
  });

  afterEach(() => vi.clearAllMocks());

  it('renders DocumentList, filter chips are present', () => {
    const {getByText} = render(Page);
    expect(getByText('Tous')).toBeInTheDocument();
    expect(getByText('Camions')).toBeInTheDocument();
    expect(getByText('Citernes')).toBeInTheDocument();
    expect(getByText('Trajets')).toBeInTheDocument();
    expect(getByText('Maintenance')).toBeInTheDocument();
  });
});
