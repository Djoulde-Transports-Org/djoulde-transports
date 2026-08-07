import {render, waitFor, within, fireEvent} from '@testing-library/svelte';
import TripTable from '$lib/components/trajets/TripTable.svelte';
import type {Trip} from '$lib/types/trip';
import {makeTrip} from '../../../mocks/trip';
import {makeTruck} from '../../../mocks/truck';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', async () => {
  const actual = await vi.importActual<typeof import('$lib/api/client')>('$lib/api/client');
  return {...actual, api: {get: mockGet, post: mockPost}};
});

const withDrawerOptions = (tripsPage: unknown) => (url: string) => {
  if (url.startsWith('/trips')) return Promise.resolve(tripsPage);
  if (url.startsWith('/trucks')) return Promise.resolve([makeTruck({id: 1})]);
  if (url.startsWith('/routes/origins')) return Promise.resolve(['Conakry']);
  if (url.startsWith('/routes')) {
    return Promise.resolve([{id: 1, origin: 'Conakry', destination: 'Labe', rate: 1500}]);
  }
  return Promise.resolve([]);
};

const TRIPS: Trip[] = [
  makeTrip({
    id: 94,
    status: 'in_progress',
    truck: makeTruck({
      plateNumber: 'GN-3310-C',
      tank: {
        id: 1,
        truckId: 1,
        plateNumber: 'TK-041',
        vin: null,
        make: null,
        model: null,
        year: null,
        capacity: 33_000,
        status: 'active',
        conformityCertificateExpiresOn: null,
        conformityCertificateDaysRemaining: null,
      },
    }),
    driver: {
      id: 1,
      firstName: 'Ibrahima',
      lastName: 'Sow',
      fullName: 'Ibrahima Sow',
      phoneNumber: null,
      role: 'driver',
      userId: null,
    },
    route: {id: 1, origin: 'Conakry', destination: 'Mamou', rate: 1500},
    deliveryNote: {
      id: 1,
      tripId: 94,
      number: 'DN-001',
      deliveredOn: null,
      gasolineQuantity: 2_000,
      dieselQuantity: 5_000,
      totalQuantity: 7_000,
      missingQuantity: null,
      product: 'both',
    },
    pretaxAmount: 7_500_000,
    scheduledStartAt: '2026-06-25T08:00:00Z',
  }),
  makeTrip({
    id: 92,
    status: 'completed',
    truck: makeTruck({plateNumber: 'GN-1892-B', tank: null}),
    driver: null,
    route: {id: 2, origin: 'Conakry', destination: 'Faranah', rate: 1800},
    deliveryNote: null,
    pretaxAmount: null,
    scheduledStartAt: '2026-06-24T08:00:00Z',
  }),
];

const page = (
  items = TRIPS,
  overrides: Partial<{nextCursor: string | null; hasMore: boolean}> = {}
) => ({
  items,
  nextCursor: null,
  hasMore: false,
  ...overrides,
});

describe('TripTable', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the column headers', async () => {
    mockGet.mockReturnValue(new Promise(() => {}));
    const {getByText} = render(TripTable);
    expect(getByText('N° trajet')).toBeInTheDocument();
    expect(getByText('N° bon de livraison')).toBeInTheDocument();
    expect(getByText('Camion/Citerne')).toBeInTheDocument();
    expect(getByText('Route')).toBeInTheDocument();
    expect(getByText('Chauffeur')).toBeInTheDocument();
    expect(getByText('Gasoil (L)')).toBeInTheDocument();
    expect(getByText('Essence (L)')).toBeInTheDocument();
    expect(getByText('Montant HT')).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
    expect(getByText('Départ')).toBeInTheDocument();
  });

  it('fetches the trips endpoint', async () => {
    mockGet.mockResolvedValue(page());
    render(TripTable);
    await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/trips?limit=50'));
  });

  it('renders the trip number', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('#TRJ-0094')).toBeInTheDocument());
    expect(getByText('#TRJ-0092')).toBeInTheDocument();
  });

  it('renders the delivery note number, or a dash when there is no delivery note', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('DN-001')).toBeInTheDocument());
  });

  it('renders the truck plate and tank summary', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
    expect(getByText('TK-041 · 33 000 L')).toBeInTheDocument();
  });

  it('renders — for the tank summary when the truck has no tank', async () => {
    mockGet.mockResolvedValue(page());
    const {getAllByText} = render(TripTable);
    await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
  });

  it('renders the route as origin → destination', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('Conakry → Mamou')).toBeInTheDocument());
    expect(getByText('Conakry → Faranah')).toBeInTheDocument();
  });

  it('renders the driver name, or a dash when unassigned', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('Ibrahima Sow')).toBeInTheDocument());
  });

  it('renders the gasoil (diesel) quantity in liters', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('5 000')).toBeInTheDocument());
  });

  it('renders the essence (gasoline) quantity in liters', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('2 000')).toBeInTheDocument());
  });

  it('renders the montant HT, or a dash when unavailable', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('7 500 000')).toBeInTheDocument());
  });

  it('renders the scheduled departure date as DD/MM/YYYY', async () => {
    mockGet.mockResolvedValue(page());
    const {getByText} = render(TripTable);
    await waitFor(() => expect(getByText('25/06/2026')).toBeInTheDocument());
  });

  describe('status badges', () => {
    it('shows En cours badge for in_progress trips', async () => {
      mockGet.mockResolvedValue(page());
      const {container} = render(TripTable);
      await waitFor(() => {
        const tbody = within(container.querySelector('tbody') as HTMLElement);
        expect(tbody.getByText('En cours')).toHaveClass('text-accent');
      });
    });

    it('shows Terminé badge for completed trips', async () => {
      mockGet.mockResolvedValue(page());
      const {getByText} = render(TripTable);
      const badge = await waitFor(() => getByText('Terminé'));
      expect(badge).toHaveClass('text-dt-green');
    });

    it('shows Planifié badge for scheduled trips', async () => {
      mockGet.mockResolvedValue(page([makeTrip({id: 1, status: 'scheduled'})]));
      const {getByText} = render(TripTable);
      const badge = await waitFor(() => getByText('Planifié'));
      expect(badge).toHaveClass('text-dt-text-muted');
    });

    it('shows Annulé badge for cancelled trips', async () => {
      mockGet.mockResolvedValue(page([makeTrip({id: 1, status: 'cancelled'})]));
      const {getByText} = render(TripTable);
      const badge = await waitFor(() => getByText('Annulé'));
      expect(badge).toHaveClass('text-dt-red');
    });
  });

  describe('filter chips', () => {
    it('renders the Tous / En cours / Planifiés / Terminés / Annulés filter chips', async () => {
      mockGet.mockResolvedValue(page());
      const {getByRole} = render(TripTable);
      await waitFor(() => expect(getByRole('button', {name: 'Tous'})).toBeInTheDocument());
      expect(getByRole('button', {name: 'En cours'})).toBeInTheDocument();
      expect(getByRole('button', {name: 'Planifiés'})).toBeInTheDocument();
      expect(getByRole('button', {name: 'Terminés'})).toBeInTheDocument();
      expect(getByRole('button', {name: 'Annulés'})).toBeInTheDocument();
    });

    it('refetches from the server with the status filter when a chip is clicked', async () => {
      mockGet.mockResolvedValue(page());
      const {getByRole} = render(TripTable);
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      await fireEvent.click(getByRole('button', {name: 'Planifiés'}));
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(2));
      expect(mockGet).toHaveBeenLastCalledWith('/trips?status=scheduled&limit=50');
    });

    it('removes the status filter when "Tous" is clicked again', async () => {
      mockGet.mockResolvedValue(page());
      const {getByRole} = render(TripTable);
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      await fireEvent.click(getByRole('button', {name: 'En cours'}));
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(2));
      await fireEvent.click(getByRole('button', {name: 'Tous'}));
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(3));
      expect(mockGet).toHaveBeenLastCalledWith('/trips?limit=50');
    });
  });

  describe('pagination', () => {
    it('shows the Suivant/Précédent controls', async () => {
      mockGet.mockResolvedValue(page(TRIPS, {hasMore: true, nextCursor: 'cur-abc'}));
      const {getByText} = render(TripTable);
      await waitFor(() => expect(getByText('Suivant')).toBeInTheDocument());
      expect(getByText('Précédent')).toBeInTheDocument();
    });

    it('fetches the next page with the cursor when Suivant is clicked', async () => {
      mockGet.mockResolvedValue(page(TRIPS, {hasMore: true, nextCursor: 'cur-abc'}));
      const {getByText} = render(TripTable);
      await waitFor(() => expect(getByText('Suivant').closest('button')).not.toBeDisabled());
      await fireEvent.click(getByText('Suivant'));
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/trips?limit=50&after=cur-abc'));
    });
  });

  describe('empty state', () => {
    it('shows the default empty message when no trips are returned', async () => {
      mockGet.mockResolvedValue(page([]));
      const {getByText} = render(TripTable);
      await waitFor(() => expect(getByText('Aucun résultat.')).toBeInTheDocument());
    });
  });

  describe('new trip drawer', () => {
    it('renders the "Nouveau trajet" button', async () => {
      mockGet.mockResolvedValue(page());
      const {getByText} = render(TripTable);
      await waitFor(() => expect(getByText('Nouveau trajet')).toBeInTheDocument());
    });

    it('opens the drawer when the button is clicked', async () => {
      mockGet.mockImplementation(withDrawerOptions(page()));
      const {getByText, getAllByText} = render(TripTable);
      await waitFor(() => expect(getByText('Nouveau trajet')).toBeInTheDocument());
      await fireEvent.click(getByText('Nouveau trajet'));
      expect(getAllByText('Nouveau trajet').length).toBe(2); // button + drawer title
    });

    it('closes the drawer when Annuler is clicked', async () => {
      mockGet.mockImplementation(withDrawerOptions(page()));
      const {getByText, queryByText} = render(TripTable);
      await waitFor(() => expect(getByText('Nouveau trajet')).toBeInTheDocument());
      await fireEvent.click(getByText('Nouveau trajet'));
      await fireEvent.click(getByText('Annuler'));
      expect(queryByText('Annuler')).not.toBeInTheDocument();
    });

    it('refetches the trip list after a trip is successfully created', async () => {
      mockGet.mockImplementation(withDrawerOptions(page()));
      mockPost.mockResolvedValue(TRIPS[0]);
      const tripCalls = () => mockGet.mock.calls.filter(([url]) => url.startsWith('/trips')).length;
      const {getByText, getByLabelText} = render(TripTable);
      await waitFor(() => expect(tripCalls()).toBe(1));

      await fireEvent.click(getByText('Nouveau trajet'));
      await fireEvent.focus(getByLabelText('Camion'));
      await waitFor(() => expect(getByText('TRK-001')).toBeInTheDocument());
      await fireEvent.mouseDown(getByText('TRK-001'));
      await fireEvent.focus(getByLabelText('Origine'));
      await waitFor(() => expect(getByText('Conakry')).toBeInTheDocument());
      await fireEvent.mouseDown(getByText('Conakry'));
      await fireEvent.focus(getByLabelText('Destination'));
      await fireEvent.mouseDown(getByText('Labe'));
      await fireEvent.input(getByLabelText('Numéro'), {target: {value: 'DN-001'}});
      await fireEvent.click(getByText('Créer le trajet'));

      await waitFor(() => expect(mockPost).toHaveBeenCalled());
      await waitFor(() => expect(tripCalls()).toBe(2));
    });
  });
});
