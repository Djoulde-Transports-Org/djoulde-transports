import {render, waitFor} from '@testing-library/svelte';
import FleetLanes from '$lib/components/dashboard/FleetLanes.svelte';
import {makeTruck} from '../../../mocks/truck';

const mockGetTrucks = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/trucks', () => ({getTrucks: mockGetTrucks}));

vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

const TRUCKS = [
  makeTruck({
    id: 1,
    plateNumber: 'AB 1234 CD',
    status: 'on_trip',
    driver: {
      id: 1,
      firstName: 'Mamadou',
      lastName: 'Diallo',
      fullName: 'Mamadou Diallo',
      phoneNumber: null,
      role: 'driver',
      userId: null,
    },
  }),
  makeTruck({id: 2, plateNumber: 'EF 5678 GH', status: 'in_maintenance', driver: null}),
  makeTruck({
    id: 3,
    plateNumber: 'IJ 9012 KL',
    status: 'ready',
    driver: {
      id: 2,
      firstName: 'Ibra',
      lastName: 'Sow',
      fullName: 'Ibra Sow',
      phoneNumber: null,
      role: 'driver',
      userId: null,
    },
  }),
];

const ok = (trucks = TRUCKS) => ({data: trucks, error: null});
const err = (message: string) => ({data: [], error: message});

describe('FleetLanes', () => {
  afterEach(() => vi.clearAllMocks());

  describe('loading state', () => {
    it('shows skeleton rows while fetching', () => {
      mockGetTrucks.mockReturnValue(new Promise(() => {}));
      const {container} = render(FleetLanes);
      expect(container.querySelectorAll('.animate-pulse').length).toBeGreaterThan(0);
    });

    it('always shows the widget header', () => {
      mockGetTrucks.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(FleetLanes);
      expect(getByText('État de la flotte')).toBeInTheDocument();
    });

    it('always shows the "Voir tout" link', () => {
      mockGetTrucks.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(FleetLanes);
      expect(getByText('Voir tout →')).toBeInTheDocument();
    });
  });

  describe('navigation', () => {
    it('"Voir tout" links to /flotte', () => {
      mockGetTrucks.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(FleetLanes);
      expect(getByText('Voir tout →').closest('a')).toHaveAttribute('href', '/flotte');
    });
  });

  describe('loaded state', () => {
    it('calls getTrucks on mount', async () => {
      mockGetTrucks.mockResolvedValue(ok([]));
      render(FleetLanes);
      await waitFor(() => expect(mockGetTrucks).toHaveBeenCalledOnce());
    });

    it('renders plate numbers', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('AB 1234 CD')).toBeInTheDocument());
      expect(getByText('EF 5678 GH')).toBeInTheDocument();
      expect(getByText('IJ 9012 KL')).toBeInTheDocument();
    });

    it('shows EN ROUTE badge for on_trip trucks', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('EN ROUTE')).toBeInTheDocument());
    });

    it('shows MAINTENANCE badge for in_maintenance trucks', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('MAINTENANCE')).toBeInTheDocument());
    });

    it('shows PRÊT badge for ready trucks', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('PRÊT')).toBeInTheDocument());
    });

    it('shows driver name when assigned', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      expect(getByText('Ibra Sow')).toBeInTheDocument();
    });

    it('shows — when no driver is assigned', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {getAllByText} = render(FleetLanes);
      await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
    });

    it('hides skeleton after loading', async () => {
      mockGetTrucks.mockResolvedValue(ok());
      const {container} = render(FleetLanes);
      await waitFor(() =>
        expect(container.querySelector('.animate-pulse')).not.toBeInTheDocument()
      );
    });
  });

  describe('empty state', () => {
    it('shows empty message when no trucks returned', async () => {
      mockGetTrucks.mockResolvedValue(ok([]));
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('Aucun camion.')).toBeInTheDocument());
    });
  });

  describe('error state', () => {
    it('shows the error message returned by getTrucks', async () => {
      mockGetTrucks.mockResolvedValue(err('Network error'));
      const {getByText} = render(FleetLanes);
      await waitFor(() => expect(getByText('Network error')).toBeInTheDocument());
    });

    it('does not show the empty message when there is an error', async () => {
      mockGetTrucks.mockResolvedValue(err('Network error'));
      const {queryByText} = render(FleetLanes);
      await waitFor(() => expect(queryByText('Aucun camion.')).not.toBeInTheDocument());
    });
  });
});
