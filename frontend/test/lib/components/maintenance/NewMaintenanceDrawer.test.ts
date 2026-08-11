import {render, fireEvent, waitFor} from '@testing-library/svelte';
import NewMaintenanceDrawer from '$lib/components/maintenance/NewMaintenanceDrawer.svelte';
import {makeTruck} from '../../../mocks/truck';
import {makeEmployee} from '../../../mocks/employee';
import {makeMaintenance} from '../../../mocks/maintenance';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, post: mockPost}}));

const withOptions =
  (trucks: unknown[], technicians: unknown[], kinds: unknown[] = []) =>
  (url: string): Promise<unknown> => {
    if (url.startsWith('/trucks')) return Promise.resolve(trucks);
    if (url.startsWith('/employees')) return Promise.resolve(technicians);
    if (url.startsWith('/maintenance_kinds')) return Promise.resolve(kinds);
    return Promise.resolve([]);
  };

const fillRequiredFields = async (
  getByLabelText: (text: string) => HTMLElement,
  getByText: (text: string) => HTMLElement
) => {
  const truckInput = getByLabelText('Camion');
  await fireEvent.focus(truckInput);
  await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
  await fireEvent.mouseDown(getByText('GN-3310-C'));

  const kindInput = getByLabelText('Type de maintenance');
  await fireEvent.focus(kindInput);
  await fireEvent.input(kindInput, {target: {value: 'repair'}});
  await waitFor(() => expect(getByText('+ Créer « repair »')).toBeInTheDocument());
  await fireEvent.mouseDown(getByText('+ Créer « repair »'));

  await fireEvent.input(getByLabelText('Date de début'), {target: {value: '2026-06-25'}});
};

describe('NewMaintenanceDrawer', () => {
  afterEach(() => vi.clearAllMocks());

  describe('when closed', () => {
    it('renders nothing', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByRole} = render(NewMaintenanceDrawer, {
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
      const {getByText} = render(NewMaintenanceDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(getByText('Ouvrir un chantier')).toBeInTheDocument();
    });

    it('fetches all trucks', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      render(NewMaintenanceDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(mockGet).toHaveBeenCalledWith('/trucks?per_page=100&page=1');
    });

    it('fetches employees filtered to the mechanic role', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      render(NewMaintenanceDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(mockGet).toHaveBeenCalledWith('/employees?role=mechanic');
    });

    it('shows the fetched trucks when the camion field is focused', async () => {
      mockGet.mockImplementation(withOptions([makeTruck({id: 1, plateNumber: 'GN-3310-C'})], []));
      const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.focus(getByLabelText('Camion'));
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
    });

    it('fetches maintenance kinds', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      render(NewMaintenanceDrawer, {open: true, onClose: vi.fn(), onCreated: vi.fn()});
      expect(mockGet).toHaveBeenCalledWith('/maintenance_kinds');
    });

    it('shows the translated label for a known kind fetched from the API', async () => {
      mockGet.mockImplementation(withOptions([], [], [{id: 1, name: 'oil_change'}]));
      const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.focus(getByLabelText('Type de maintenance'));
      await waitFor(() => expect(getByText('Vidange')).toBeInTheDocument());
    });

    it('shows a create option for a kind name that matches nothing yet', async () => {
      mockGet.mockImplementation(withOptions([], [], [{id: 1, name: 'oil_change'}]));
      const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      const kindInput = getByLabelText('Type de maintenance');
      await fireEvent.focus(kindInput);
      await fireEvent.input(kindInput, {target: {value: 'Freinage'}});
      await waitFor(() => expect(getByText('+ Créer « Freinage »')).toBeInTheDocument());
    });

    it('only lists technicians that have a linked user account', async () => {
      mockGet.mockImplementation(
        withOptions(
          [],
          [
            makeEmployee({id: 1, fullName: 'Mamadou Diallo', userId: 5}),
            makeEmployee({id: 2, fullName: 'Ibrahima Bah', userId: null}),
          ]
        )
      );
      const {getByLabelText, getByText, queryByText} = render(NewMaintenanceDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.focus(getByLabelText('Technicien (optionnel)'));
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      expect(queryByText('Ibrahima Bah')).not.toBeInTheDocument();
    });

    it('calls onClose when clicking the overlay', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByRole} = render(NewMaintenanceDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByRole('presentation', {hidden: true}));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking the close button', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByLabelText} = render(NewMaintenanceDrawer, {
        open: true,
        onClose,
        onCreated: vi.fn(),
      });
      await fireEvent.click(getByLabelText('Fermer'));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when pressing Escape', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      render(NewMaintenanceDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking Annuler', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByText} = render(NewMaintenanceDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByText('Annuler'));
      expect(onClose).toHaveBeenCalled();
    });

    describe('validation', () => {
      it('shows required errors when submitting an empty form', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Ouvrir le chantier'));
        await waitFor(() => expect(getByText('Le camion est requis')).toBeInTheDocument());
        expect(getByText('Le type de maintenance est requis')).toBeInTheDocument();
        expect(getByText('La date de début est requise')).toBeInTheDocument();
      });

      it('does not call createMaintenance when required fields are missing', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Ouvrir le chantier'));
        await waitFor(() => expect(getByText('Le camion est requis')).toBeInTheDocument());
        expect(mockPost).not.toHaveBeenCalled();
      });
    });

    describe('submission', () => {
      it('submits only the required fields when optional fields are blank', async () => {
        mockGet.mockImplementation(withOptions([makeTruck({id: 1, plateNumber: 'GN-3310-C'})], []));
        mockPost.mockResolvedValue(makeMaintenance());
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith('/maintenances/create', {
          truckId: 1,
          performedOn: '2026-06-25',
          kind: 'repair',
        });
      });

      it('submits the raw kind name when an existing translated kind is chosen', async () => {
        mockGet.mockImplementation(
          withOptions(
            [makeTruck({id: 1, plateNumber: 'GN-3310-C'})],
            [],
            [{id: 1, name: 'oil_change'}]
          )
        );
        mockPost.mockResolvedValue(makeMaintenance());
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        const truckInput = getByLabelText('Camion');
        await fireEvent.focus(truckInput);
        await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('GN-3310-C'));

        const kindInput = getByLabelText('Type de maintenance');
        await fireEvent.focus(kindInput);
        await waitFor(() => expect(getByText('Vidange')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Vidange'));

        await fireEvent.input(getByLabelText('Date de début'), {target: {value: '2026-06-25'}});
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/maintenances/create',
          expect.objectContaining({kind: 'oil_change'})
        );
      });

      it('includes the selected performedById', async () => {
        mockGet.mockImplementation(
          withOptions(
            [makeTruck({id: 1, plateNumber: 'GN-3310-C'})],
            [makeEmployee({id: 1, fullName: 'Mamadou Diallo', userId: 5})]
          )
        );
        mockPost.mockResolvedValue(makeMaintenance());
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        const techInput = getByLabelText('Technicien (optionnel)');
        await fireEvent.focus(techInput);
        await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
        await fireEvent.mouseDown(getByText('Mamadou Diallo'));
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/maintenances/create',
          expect.objectContaining({performedById: 5})
        );
      });

      it('includes the estimated duration when filled in', async () => {
        mockGet.mockImplementation(withOptions([makeTruck({id: 1, plateNumber: 'GN-3310-C'})], []));
        mockPost.mockResolvedValue(makeMaintenance());
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.input(getByLabelText('Durée estimée (h) (optionnel)'), {
          target: {value: '4'},
        });
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/maintenances/create',
          expect.objectContaining({estimatedDuration: 4})
        );
      });

      it('sends the estimated cost as a single part line item', async () => {
        mockGet.mockImplementation(withOptions([makeTruck({id: 1, plateNumber: 'GN-3310-C'})], []));
        mockPost.mockResolvedValue(makeMaintenance());
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.input(getByLabelText('Coût estimé (GNF) (optionnel)'), {
          target: {value: '850000'},
        });
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/maintenances/create',
          expect.objectContaining({parts: [{name: 'Coût estimé', price: 850_000}]})
        );
      });

      it('calls onCreated and onClose on success', async () => {
        mockGet.mockImplementation(withOptions([makeTruck({id: 1, plateNumber: 'GN-3310-C'})], []));
        mockPost.mockResolvedValue(makeMaintenance());
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(onCreated).toHaveBeenCalled());
        expect(onClose).toHaveBeenCalled();
      });

      it('shows the API error and does not close on failure', async () => {
        mockGet.mockImplementation(withOptions([makeTruck({id: 1, plateNumber: 'GN-3310-C'})], []));
        mockPost.mockRejectedValue(new Error('Camion déjà en maintenance'));
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getByLabelText, getByText} = render(NewMaintenanceDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Ouvrir le chantier'));

        await waitFor(() => expect(getByText('Camion déjà en maintenance')).toBeInTheDocument());
        expect(onCreated).not.toHaveBeenCalled();
        expect(onClose).not.toHaveBeenCalled();
      });
    });
  });
});
