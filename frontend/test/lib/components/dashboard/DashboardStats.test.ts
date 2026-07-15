import {render, waitFor} from '@testing-library/svelte';
import DashboardStats from '$lib/components/dashboard/DashboardStats.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

const METRICS = {
  trucks: {total: 7, ready: 2, on_trip: 4, in_maintenance: 1},
  trips_in_progress: 3,
  liters_delivered_this_month: 12500,
  billing_amount_ht_this_month: 850000,
};

describe('DashboardStats', () => {
  afterEach(() => vi.clearAllMocks());

  describe('loading state', () => {
    it('shows skeleton elements while fetching', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {container} = render(DashboardStats);
      expect(container.querySelectorAll('.animate-pulse').length).toBeGreaterThan(0);
    });

    it('renders all four card labels', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(DashboardStats);
      expect(getByText('Camions actifs')).toBeInTheDocument();
      expect(getByText('Trajets en cours')).toBeInTheDocument();
      expect(getByText('Litres livrés')).toBeInTheDocument();
      expect(getByText('Facturation HT')).toBeInTheDocument();
    });
  });

  describe('loaded state', () => {
    it('calls the dashboard endpoint', async () => {
      mockGet.mockResolvedValue(METRICS);
      render(DashboardStats);
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/dashboard'));
    });

    it('displays total truck count', async () => {
      mockGet.mockResolvedValue(METRICS);
      const {getByText} = render(DashboardStats);
      await waitFor(() => expect(getByText('7')).toBeInTheDocument());
    });

    it('displays truck breakdown sub-text', async () => {
      mockGet.mockResolvedValue(METRICS);
      const {getByText} = render(DashboardStats);
      await waitFor(() =>
        expect(getByText('4 en route · 2 prêts · 1 maintenance')).toBeInTheDocument()
      );
    });

    it('displays trips in progress', async () => {
      mockGet.mockResolvedValue(METRICS);
      const {getByText} = render(DashboardStats);
      await waitFor(() => expect(getByText('3')).toBeInTheDocument());
    });

    it('displays formatted liters', async () => {
      mockGet.mockResolvedValue(METRICS);
      const {getByText} = render(DashboardStats);
      await waitFor(() => expect(getByText('12 500 L')).toBeInTheDocument());
    });

    it('displays formatted billing amount', async () => {
      mockGet.mockResolvedValue(METRICS);
      const {getByText} = render(DashboardStats);
      await waitFor(() => expect(getByText('850 000 GNF')).toBeInTheDocument());
    });

    it('hides skeletons after loading', async () => {
      mockGet.mockResolvedValue(METRICS);
      const {container} = render(DashboardStats);
      await waitFor(() =>
        expect(container.querySelector('.animate-pulse')).not.toBeInTheDocument()
      );
    });
  });
});
