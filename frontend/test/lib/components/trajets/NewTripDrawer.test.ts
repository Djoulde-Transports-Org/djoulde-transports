import {render, fireEvent, waitFor} from '@testing-library/svelte';
import NewTripDrawer from '$lib/components/trajets/NewTripDrawer.svelte';
import {ApiRequestError} from '$lib/api/client';
import {makeTruck} from '../../../mocks/truck';
import {makeTrip} from '../../../mocks/trip';
import {makeEmployee} from '../../../mocks/employee';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', async () => {
  const actual = await vi.importActual<typeof import('$lib/api/client')>('$lib/api/client');
  return {...actual, api: {get: mockGet, post: mockPost}};
});

const TRUCK_WITH_DRIVER = makeTruck({
  id: 1,
  plateNumber: 'GN-3310-C',
  make: 'Volvo',
  model: 'FH',
  year: 2019,
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
  driver: {
    id: 9,
    firstName: 'Ibrahima',
    lastName: 'Bah',
    fullName: 'Ibrahima Bah',
    phoneNumber: null,
    role: 'driver',
    userId: null,
  },
});

const TRUCK_NO_DRIVER = makeTruck({
  id: 2,
  plateNumber: 'GN-1892-B',
  tank: null,
  driver: null,
});

const ROUTES = [
  {id: 1, origin: 'Conakry', destination: 'Labe', rate: 1500},
  {id: 2, origin: 'Conakry', destination: 'Mamou', rate: 1800},
];

const DRIVERS = [makeEmployee({id: 5, fullName: 'Mamadou Diallo'})];

const mockGetByUrl = (
  overrides: {
    trucks?: unknown;
    routes?: {id: number; origin: string; destination: string; rate: number}[];
    origins?: string[];
    drivers?: unknown;
  } = {}
) => {
  const routesData = overrides.routes ?? ROUTES;
  mockGet.mockImplementation((url: string) => {
    if (url.startsWith('/trucks')) return Promise.resolve(overrides.trucks ?? [TRUCK_WITH_DRIVER]);
    if (url.startsWith('/routes/origins')) {
      const derived = Array.from(new Set(routesData.map((r) => r.origin)));
      return Promise.resolve(overrides.origins ?? derived);
    }
    if (url.startsWith('/routes')) {
      const origin = new URL(url, 'http://localhost').searchParams.get('origin');
      const filtered = origin ? routesData.filter((r) => r.origin === origin) : routesData;
      return Promise.resolve(filtered);
    }
    if (url.startsWith('/employees')) return Promise.resolve(overrides.drivers ?? DRIVERS);
    return Promise.resolve([]);
  });
};

describe('NewTripDrawer', () => {
  afterEach(() => vi.clearAllMocks());

  describe('when closed', () => {
    it('renders nothing', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByRole} = render(NewTripDrawer, {
        open: false,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(queryByRole('dialog', {hidden: true})).not.toBeInTheDocument();
    });
  });

  describe('when open', () => {
    it('renders the drawer title', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(NewTripDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(getByText('Nouveau trajet')).toBeInTheDocument();
    });

    it('renders the numbered section headers', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(NewTripDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(getByText('Convoi')).toBeInTheDocument();
      expect(getByText('Itinéraire')).toBeInTheDocument();
      expect(getByText('Chauffeur')).toBeInTheDocument();
      expect(getByText('Bon de livraison')).toBeInTheDocument();
    });

    it('fetches trucks, route origins and drivers', () => {
      mockGetByUrl();
      render(NewTripDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(mockGet).toHaveBeenCalledWith('/trucks?per_page=100&page=1');
      expect(mockGet).toHaveBeenCalledWith('/routes/origins');
      expect(mockGet).toHaveBeenCalledWith('/employees?role=driver');
    });

    describe('pairing card', () => {
      it('shows the truck plate and tank summary once a truck with a tank is selected', async () => {
        mockGetByUrl();
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Camion'));
        await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-3310-C'));
        expect(getByText('TK-041 · 33 000 L')).toBeInTheDocument();
      });

      it('shows — for the tank summary when the selected truck has no tank', async () => {
        mockGetByUrl({trucks: [TRUCK_NO_DRIVER]});
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Camion'));
        await waitFor(() => expect(getByText('GN-1892-B')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-1892-B'));
        expect(getByText('—')).toBeInTheDocument();
      });

      it('does not show the pairing card before a truck is selected', () => {
        mockGetByUrl();
        const {queryByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        expect(queryByText('Citerne appairée')).not.toBeInTheDocument();
      });
    });

    describe('origin / destination', () => {
      it('shows only destinations for the selected origin', async () => {
        mockGetByUrl();
        const {getByLabelText, getByText, queryByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Origine'));
        await waitFor(() => expect(getByText('Conakry')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Conakry'));
        await fireEvent.focus(getByLabelText('Destination'));
        expect(getByText('Labe')).toBeInTheDocument();
        expect(getByText('Mamou')).toBeInTheDocument();
        expect(queryByText('Faranah')).not.toBeInTheDocument();
      });

      it('resets the destination when the origin changes', async () => {
        mockGetByUrl({
          routes: [
            {id: 1, origin: 'Conakry', destination: 'Labe', rate: 1500},
            {id: 2, origin: 'Kindia', destination: 'Mamou', rate: 1200},
          ],
        });
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Origine'));
        await waitFor(() => expect(getByText('Conakry')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Conakry'));
        await fireEvent.focus(getByLabelText('Destination'));
        await fireEvent.mouseDown(getByText('Labe'));
        await fireEvent.blur(getByLabelText('Destination'));
        expect(getByLabelText('Destination')).toHaveValue('Labe');

        await fireEvent.focus(getByLabelText('Origine'));
        await fireEvent.mouseDown(getByText('Kindia'));
        await fireEvent.blur(getByLabelText('Origine'));
        expect(getByLabelText('Destination')).toHaveValue('');
      });

      it("shows a hint to pick an origin first when destination hasn't loaded", () => {
        mockGetByUrl();
        const {getByLabelText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        expect(getByLabelText('Destination')).toHaveAttribute(
          'placeholder',
          "Sélectionnez d'abord l'origine"
        );
      });

      it('fetches all origins up front, then fetches routes filtered by origin once selected', async () => {
        mockGetByUrl();
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/routes/origins'));
        await fireEvent.focus(getByLabelText('Origine'));
        await waitFor(() => expect(getByText('Conakry')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Conakry'));
        await waitFor(() =>
          expect(mockGet).toHaveBeenCalledWith('/routes?per_page=100&origin=Conakry')
        );
      });

      it('does not fetch destination routes before an origin is selected', () => {
        mockGetByUrl();
        render(NewTripDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
        expect(mockGet).not.toHaveBeenCalledWith(expect.stringContaining('origin='));
      });
    });

    describe('route rate', () => {
      it('shows the rate once origin and destination are selected', async () => {
        mockGetByUrl();
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Origine'));
        await waitFor(() => expect(getByText('Conakry')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Conakry'));
        await fireEvent.focus(getByLabelText('Destination'));
        await fireEvent.mouseDown(getByText('Labe'));
        expect(getByText('1 500 / L')).toBeInTheDocument();
      });
    });

    describe('habituel hint', () => {
      it('shows the regular driver hint when the selected truck has a driver', async () => {
        mockGetByUrl();
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Camion'));
        await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-3310-C'));
        expect(getByText(/Chauffeur habituel/)).toBeInTheDocument();
        expect(getByText('Ibrahima Bah')).toBeInTheDocument();
      });

      it('does not show the hint when the selected truck has no regular driver', async () => {
        mockGetByUrl({trucks: [TRUCK_NO_DRIVER]});
        const {getByLabelText, getByText, queryByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Camion'));
        await waitFor(() => expect(getByText('GN-1892-B')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-1892-B'));
        expect(queryByText(/Chauffeur habituel/)).not.toBeInTheDocument();
      });
    });

    describe('tank fill visualizer', () => {
      it('does not show the bar before a truck is selected', () => {
        mockGetByUrl();
        const {queryByTestId} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        expect(queryByTestId('tank-fill-bar')).not.toBeInTheDocument();
      });

      it('reads the capacity from the selected truck and updates as quantities are entered', async () => {
        mockGetByUrl();
        const {getByLabelText, getByText, getByTestId} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.focus(getByLabelText('Camion'));
        await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-3310-C'));

        expect(getByTestId('tank-fill-bar')).toBeInTheDocument();
        expect(getByText('33 000 L')).toBeInTheDocument();
        expect(
          getByText('Renseignez les quantités pour visualiser le remplissage')
        ).toBeInTheDocument();

        await fireEvent.input(getByLabelText('Gasoil (L)'), {target: {value: '20000'}});
        await fireEvent.input(getByLabelText('Essence (L)'), {target: {value: '13000'}});
        expect(getByText('Citerne remplie exactement')).toBeInTheDocument();
      });
    });

    it('calls onClose when clicking the overlay', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByRole} = render(NewTripDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByRole('presentation', {hidden: true}));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking the close button', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByLabelText} = render(NewTripDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByLabelText('Fermer'));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when pressing Escape', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      render(NewTripDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking Annuler', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByText} = render(NewTripDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByText('Annuler'));
      expect(onClose).toHaveBeenCalled();
    });

    describe('validation', () => {
      it('shows required errors when submitting an empty form', async () => {
        mockGetByUrl();
        const {getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Créer le trajet'));
        await waitFor(() => expect(getByText('Le camion est requis')).toBeInTheDocument());
        expect(getByText('La route est requise')).toBeInTheDocument();
        expect(getByText('Le numéro du bon de livraison est requis')).toBeInTheDocument();
      });

      it('does not call createTrip when required fields are missing', async () => {
        mockGetByUrl();
        const {getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Créer le trajet'));
        await waitFor(() => expect(getByText('Le camion est requis')).toBeInTheDocument());
        expect(mockPost).not.toHaveBeenCalled();
      });
    });

    describe('submission', () => {
      const fillRequiredFields = async (
        getByLabelText: (text: string) => HTMLElement,
        getByText: (text: string) => HTMLElement
      ) => {
        await fireEvent.focus(getByLabelText('Camion'));
        await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-3310-C'));
        await fireEvent.focus(getByLabelText('Origine'));
        await waitFor(() => expect(getByText('Conakry')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Conakry'));
        await fireEvent.focus(getByLabelText('Destination'));
        await fireEvent.mouseDown(getByText('Labe'));
        await fireEvent.input(getByLabelText('Numéro'), {target: {value: 'DN-001'}});
      };

      it('submits only the required fields when optional fields are blank', async () => {
        mockGetByUrl();
        mockPost.mockResolvedValue(makeTrip());
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith('/trips/create', {
          truckId: 1,
          routeId: 1,
          deliveryNote: {number: 'DN-001'},
        });
      });

      it('includes scheduled dates when filled in', async () => {
        mockGetByUrl();
        mockPost.mockResolvedValue(makeTrip());
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.input(getByLabelText('Départ'), {target: {value: '2026-07-10T08:00'}});
        await fireEvent.input(getByLabelText('Arrivée'), {target: {value: '2026-07-10T18:00'}});
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/trips/create',
          expect.objectContaining({
            scheduledStartAt: '2026-07-10T08:00',
            scheduledEndAt: '2026-07-10T18:00',
          })
        );
      });

      it('includes fuel quantities when filled in', async () => {
        mockGetByUrl();
        mockPost.mockResolvedValue(makeTrip());
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.input(getByLabelText('Gasoil (L)'), {target: {value: '20000'}});
        await fireEvent.input(getByLabelText('Essence (L)'), {target: {value: '13000'}});
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/trips/create',
          expect.objectContaining({
            deliveryNote: {number: 'DN-001', dieselQuantity: 20_000, gasolineQuantity: 13_000},
          })
        );
      });

      it('includes the selected driverId', async () => {
        mockGetByUrl();
        mockPost.mockResolvedValue(makeTrip());
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        const driverInput = getByLabelText('Affectation');
        await fireEvent.focus(driverInput);
        await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Mamadou Diallo'));
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/trips/create',
          expect.objectContaining({driverId: 5})
        );
      });

      it('calls onCreated and onClose on success', async () => {
        mockGetByUrl();
        mockPost.mockResolvedValue(makeTrip());
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() => expect(onCreated).toHaveBeenCalled());
        expect(onClose).toHaveBeenCalled();
      });

      it('shows the API error and does not close on failure', async () => {
        mockGetByUrl();
        mockPost.mockRejectedValue(new Error('Numéro déjà utilisé'));
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() => expect(getByText('Numéro déjà utilisé')).toBeInTheDocument());
        expect(onCreated).not.toHaveBeenCalled();
        expect(onClose).not.toHaveBeenCalled();
      });

      it('shows the detailed validation message when the tank capacity mismatches', async () => {
        mockGetByUrl();
        mockPost.mockRejectedValue(
          new ApiRequestError('validation_failed', 'Validation failed.', {
            base: ['loaded quantity (1100 L) is less than the tank capacity (1500 L)'],
          })
        );
        const {getByLabelText, getByText} = render(NewTripDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Créer le trajet'));

        await waitFor(() =>
          expect(
            getByText('loaded quantity (1100 L) is less than the tank capacity (1500 L)')
          ).toBeInTheDocument()
        );
      });
    });
  });
});
