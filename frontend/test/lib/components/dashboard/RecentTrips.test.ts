import {render, waitFor} from '@testing-library/svelte';
import RecentTrips from '$lib/components/dashboard/RecentTrips.svelte';
import {makeTrip} from '../../../mocks/trip';
import {makeTruck} from '../../../mocks/truck';

const mockGetTrips = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/trips', () => ({getTrips: mockGetTrips}));

vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

const TRIPS = [
  makeTrip({
    id: 94,
    status: 'in_progress',
    truck: makeTruck({plate_number: 'GN-3310-C'}),
    driver: {
      id: 1,
      first_name: 'Ibrahima',
      last_name: 'Sow',
      full_name: 'Ibrahima Sow',
      phone_number: null,
      role: 'driver',
      user_id: null,
    },
    route: {id: 1, origin: 'Conakry', destination: 'Mamou', rate: 1500},
    delivery_note: {
      id: 1,
      trip_id: 94,
      number: 'DN-001',
      delivered_on: null,
      gasoline_quantity: 0,
      diesel_quantity: 33_000,
      total_quantity: 33_000,
      missing_quantity: null,
      product: 'diesel',
    },
    scheduled_start_at: '2026-06-25T08:00:00Z',
  }),
  makeTrip({
    id: 92,
    status: 'completed',
    truck: makeTruck({plate_number: 'GN-1892-B'}),
    driver: null,
    route: {id: 2, origin: 'Conakry', destination: 'Faranah', rate: 1800},
    delivery_note: null,
    scheduled_start_at: '2026-06-24T08:00:00Z',
  }),
];

const ok = (trips = TRIPS) => ({data: trips, error: null});
const err = (message: string) => ({data: [], error: message});

describe('RecentTrips', () => {
  afterEach(() => vi.clearAllMocks());

  describe('loading state', () => {
    it('shows skeleton rows while fetching', () => {
      mockGetTrips.mockReturnValue(new Promise(() => {}));
      const {container} = render(RecentTrips);
      expect(container.querySelectorAll('.animate-pulse').length).toBeGreaterThan(0);
    });

    it('always shows the widget header', () => {
      mockGetTrips.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(RecentTrips);
      expect(getByText('Derniers trajets')).toBeInTheDocument();
    });

    it('always shows the "Voir tout" link', () => {
      mockGetTrips.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(RecentTrips);
      expect(getByText('Voir tout →')).toBeInTheDocument();
    });
  });

  describe('navigation', () => {
    it('"Voir tout" links to /trajets', () => {
      mockGetTrips.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(RecentTrips);
      expect(getByText('Voir tout →').closest('a')).toHaveAttribute('href', '/trajets');
    });
  });

  describe('loaded state', () => {
    it('calls getTrips on mount', async () => {
      mockGetTrips.mockResolvedValue(ok([]));
      render(RecentTrips);
      await waitFor(() => expect(mockGetTrips).toHaveBeenCalledOnce());
    });

    it('renders the trip number', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('#TRJ-0094')).toBeInTheDocument());
      expect(getByText('#TRJ-0092')).toBeInTheDocument();
    });

    it('renders the truck plate number', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      expect(getByText('GN-1892-B')).toBeInTheDocument();
    });

    it('renders the route as origin → destination', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Conakry → Mamou')).toBeInTheDocument());
      expect(getByText('Conakry → Faranah')).toBeInTheDocument();
    });

    it('renders the driver name when assigned', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Ibrahima Sow')).toBeInTheDocument());
    });

    it('renders — when no driver is assigned', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getAllByText} = render(RecentTrips);
      await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
    });

    it('renders the delivered quantity in liters', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('33 000 L')).toBeInTheDocument());
    });

    it('shows En cours badge for in_progress trips', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('En cours')).toBeInTheDocument());
    });

    it('shows Terminé badge for completed trips', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Terminé')).toBeInTheDocument());
    });

    it('shows Planifié badge for scheduled trips', async () => {
      mockGetTrips.mockResolvedValue(ok([makeTrip({id: 1, status: 'scheduled'})]));
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Planifié')).toBeInTheDocument());
    });

    it('shows Annulé badge for cancelled trips', async () => {
      mockGetTrips.mockResolvedValue(ok([makeTrip({id: 1, status: 'cancelled'})]));
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Annulé')).toBeInTheDocument());
    });

    it('renders the scheduled date as DD/MM', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('25/06')).toBeInTheDocument());
      expect(getByText('24/06')).toBeInTheDocument();
    });

    it('hides skeleton after loading', async () => {
      mockGetTrips.mockResolvedValue(ok());
      const {container} = render(RecentTrips);
      await waitFor(() =>
        expect(container.querySelector('.animate-pulse')).not.toBeInTheDocument()
      );
    });
  });

  describe('empty state', () => {
    it('shows empty message when no trips returned', async () => {
      mockGetTrips.mockResolvedValue(ok([]));
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Aucun trajet.')).toBeInTheDocument());
    });
  });

  describe('error state', () => {
    it('shows the error message returned by getTrips', async () => {
      mockGetTrips.mockResolvedValue(err('Network error'));
      const {getByText} = render(RecentTrips);
      await waitFor(() => expect(getByText('Network error')).toBeInTheDocument());
    });

    it('does not show the empty message when there is an error', async () => {
      mockGetTrips.mockResolvedValue(err('Network error'));
      const {queryByText} = render(RecentTrips);
      await waitFor(() => expect(queryByText('Aucun trajet.')).not.toBeInTheDocument());
    });
  });
});
