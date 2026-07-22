import {render, fireEvent, waitFor} from '@testing-library/svelte';
import AddTruckDrawer from '$lib/components/flotte/AddTruckDrawer.svelte';
import {makeEmployee} from '../../../mocks/employee';
import {makeTruck} from '../../../mocks/truck';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, post: mockPost}}));

const fillRequiredFields = async (
  getAllByLabelText: (text: string) => HTMLElement[],
  getByLabelText: (text: string) => HTMLElement
) => {
  await fireEvent.input(getAllByLabelText('Immatriculation')[0], {target: {value: 'NEW-001'}});
  await fireEvent.input(getAllByLabelText('Modèle')[0], {target: {value: 'FH'}});
  await fireEvent.input(getAllByLabelText('Année')[0], {target: {value: '2024'}});
  await fireEvent.input(getAllByLabelText('Immatriculation')[1], {target: {value: 'TK-001'}});
  await fireEvent.input(getByLabelText('Capacité (L)'), {target: {value: '30000'}});
};

describe('AddTruckDrawer', () => {
  afterEach(() => vi.clearAllMocks());

  describe('when closed', () => {
    it('renders nothing', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByRole} = render(AddTruckDrawer, {
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
      const {getByText} = render(AddTruckDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(getByText('Ajouter un camion')).toBeInTheDocument();
    });

    it('renders the numbered section headers', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(AddTruckDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(getByText('Tracteur')).toBeInTheDocument();
      expect(getByText('Citerne')).toBeInTheDocument();
      expect(getByText('Chauffeur')).toBeInTheDocument();
      expect(getByText('Documents')).toBeInTheDocument();
    });

    it('pre-selects Prêt as the truck status', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByLabelText} = render(AddTruckDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(getByLabelText('Statut (optionnel)')).toHaveValue('ready');
    });

    it('fetches drivers filtered to the driver role', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      render(AddTruckDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(mockGet).toHaveBeenCalledWith('/employees?role=driver');
    });

    it('shows the fetched drivers when the affectation field is focused', async () => {
      mockGet.mockResolvedValue([makeEmployee({id: 1, full_name: 'Ibrahima Bah'})]);
      const {getByLabelText, getByText} = render(AddTruckDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.focus(getByLabelText('Affectation'));
      await waitFor(() => expect(getByText('Ibrahima Bah')).toBeInTheDocument());
    });

    it('filters the driver list as text is typed', async () => {
      mockGet.mockResolvedValue([
        makeEmployee({id: 1, full_name: 'Ibrahima Bah'}),
        makeEmployee({id: 2, full_name: 'Mamadou Diallo'}),
      ]);
      const {getByLabelText, getByText, queryByText} = render(AddTruckDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.input(input, {target: {value: 'Ibra'}});
      expect(getByText('Ibrahima Bah')).toBeInTheDocument();
      expect(queryByText('Mamadou Diallo')).not.toBeInTheDocument();
    });

    it('calls onClose when clicking the overlay', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByRole} = render(AddTruckDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByRole('presentation', {hidden: true}));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking the close button', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByLabelText} = render(AddTruckDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByLabelText('Fermer'));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when pressing Escape', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      render(AddTruckDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking Annuler', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByText} = render(AddTruckDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByText('Annuler'));
      expect(onClose).toHaveBeenCalled();
    });

    describe('validation', () => {
      it('shows required errors when submitting an empty form', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(AddTruckDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Créer le camion'));
        await waitFor(() => expect(getByText("L'immatriculation est requise")).toBeInTheDocument());
        expect(getByText('Le modèle est requis')).toBeInTheDocument();
        expect(getByText("L'année est requise")).toBeInTheDocument();
        expect(getByText("L'immatriculation de la citerne est requise")).toBeInTheDocument();
        expect(getByText('La capacité est requise')).toBeInTheDocument();
      });

      it('does not call createTruck when required fields are missing', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(AddTruckDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Créer le camion'));
        await waitFor(() => expect(getByText("L'immatriculation est requise")).toBeInTheDocument());
        expect(mockPost).not.toHaveBeenCalled();
      });
    });

    describe('submission', () => {
      it('submits only the required fields when optional fields are blank', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeTruck());
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getAllByLabelText, getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getAllByLabelText, getByLabelText);
        await fireEvent.click(getByText('Créer le camion'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith('/trucks/create', {
          plate_number: 'NEW-001',
          model: 'FH',
          year: 2024,
          status: 'ready',
          tank: {plate_number: 'TK-001', capacity: 30_000},
          documents: {},
        });
      });

      it('includes optional truck and tank fields when filled in', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeTruck());
        const {getAllByLabelText, getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getAllByLabelText, getByLabelText);
        await fireEvent.input(getAllByLabelText('VIN')[0], {target: {value: 'VIN-001'}});
        await fireEvent.input(getAllByLabelText('Marque')[0], {target: {value: 'Volvo'}});
        await fireEvent.input(getAllByLabelText('Marque')[1], {target: {value: 'Magyar'}});
        await fireEvent.input(getAllByLabelText('Modèle')[1], {target: {value: 'T33'}});
        await fireEvent.input(getAllByLabelText('VIN')[1], {target: {value: 'TVIN-001'}});
        await fireEvent.input(getAllByLabelText('Année')[1], {target: {value: '2024'}});
        await fireEvent.click(getByText('Créer le camion'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/trucks/create',
          expect.objectContaining({
            vin: 'VIN-001',
            make: 'Volvo',
            tank: expect.objectContaining({
              make: 'Magyar',
              model: 'T33',
              vin: 'TVIN-001',
              year: 2024,
            }),
          })
        );
      });

      it('includes the document expiry dates that were filled in', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeTruck());
        const {getAllByLabelText, getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getAllByLabelText, getByLabelText);
        await fireEvent.input(getByLabelText('Ass. camion'), {target: {value: '2027-01-01'}});
        await fireEvent.click(getByText('Créer le camion'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/trucks/create',
          expect.objectContaining({
            documents: {truck_insurance_expires_on: '2027-01-01'},
          })
        );
      });

      it('includes the selected driver_id', async () => {
        mockGet.mockResolvedValue([makeEmployee({id: 7, full_name: 'Ibrahima Bah'})]);
        mockPost.mockResolvedValue(makeTruck());
        const {getAllByLabelText, getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        const driverInput = getByLabelText('Affectation');
        await fireEvent.focus(driverInput);
        await waitFor(() => expect(getByText('Ibrahima Bah')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Ibrahima Bah'));
        await fillRequiredFields(getAllByLabelText, getByLabelText);
        await fireEvent.click(getByText('Créer le camion'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/trucks/create',
          expect.objectContaining({driver_id: 7})
        );
      });

      it('shows the chosen driver name after selection', async () => {
        mockGet.mockResolvedValue([makeEmployee({id: 7, full_name: 'Ibrahima Bah'})]);
        const {getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        const driverInput = getByLabelText('Affectation');
        await fireEvent.focus(driverInput);
        await waitFor(() => expect(getByText('Ibrahima Bah')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Ibrahima Bah'));
        await fireEvent.blur(driverInput);
        expect(driverInput).toHaveValue('Ibrahima Bah');
      });

      it('calls onCreated and onClose on success', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeTruck());
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getAllByLabelText, getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getAllByLabelText, getByLabelText);
        await fireEvent.click(getByText('Créer le camion'));

        await waitFor(() => expect(onCreated).toHaveBeenCalled());
        expect(onClose).toHaveBeenCalled();
      });

      it('shows the API error and does not close on failure', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockRejectedValue(new Error('Plaque déjà utilisée'));
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getAllByLabelText, getByLabelText, getByText} = render(AddTruckDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getAllByLabelText, getByLabelText);
        await fireEvent.click(getByText('Créer le camion'));

        await waitFor(() => expect(getByText('Plaque déjà utilisée')).toBeInTheDocument());
        expect(onCreated).not.toHaveBeenCalled();
        expect(onClose).not.toHaveBeenCalled();
      });
    });
  });
});
