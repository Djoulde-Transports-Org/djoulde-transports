import {render, waitFor} from '@testing-library/svelte';
import Page from '$routes/(app)/facturation/[id]/details/+page.svelte';
import {makeBillingStatement} from '../../../../mocks/billing';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (route: string) => route}));

describe('+page (facturation/[id]/details)', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the statement for the route id param', async () => {
    mockGet.mockImplementation((url: string) =>
      url.startsWith('/billing_statements/')
        ? Promise.resolve(makeBillingStatement({id: 42, number: 'S-2026-06'}))
        : Promise.resolve([])
    );
    const {getByText} = render(Page, {props: {params: {id: '42'}, data: {}}});
    await waitFor(() => expect(getByText('S-2026-06')).toBeInTheDocument());
    expect(mockGet).toHaveBeenCalledWith('/billing_statements/42');
  });
});
