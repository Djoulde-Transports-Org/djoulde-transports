import {render, fireEvent, waitFor} from '@testing-library/svelte';
import EmployeeFormDrawer from '$lib/components/employes/EmployeeFormDrawer.svelte';
import {makeEmployee} from '../../../mocks/employee';
import {makeTruck} from '../../../mocks/truck';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
const mockPatch = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, post: mockPost, patch: mockPatch}}));

const fillRequiredFields = async (getByLabelText: (text: string) => HTMLElement) => {
  await fireEvent.input(getByLabelText('Prénom'), {target: {value: 'Mamadou'}});
  await fireEvent.input(getByLabelText('Nom'), {target: {value: 'Diallo'}});
};

describe('EmployeeFormDrawer', () => {
  afterEach(() => vi.clearAllMocks());

  describe('when closed', () => {
    it('renders nothing', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByRole} = render(EmployeeFormDrawer, {
        open: false,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(queryByRole('dialog', {hidden: true})).not.toBeInTheDocument();
    });
  });

  describe('add mode (no employee prop)', () => {
    it('renders the "Ajouter un employé" title', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(EmployeeFormDrawer, {
        open: true,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(getByText('Ajouter un employé')).toBeInTheDocument();
    });

    it('renders blank required fields', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByLabelText} = render(EmployeeFormDrawer, {
        open: true,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(getByLabelText('Prénom')).toHaveValue('');
      expect(getByLabelText('Nom')).toHaveValue('');
    });

    it('defaults the role to driver and shows the truck field', () => {
      mockGet.mockResolvedValue([]);
      const {getByLabelText} = render(EmployeeFormDrawer, {
        open: true,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(getByLabelText('Rôle')).toHaveValue('driver');
      expect(getByLabelText('Camion assigné')).toBeInTheDocument();
    });

    it('fetches trucks for the assignment field', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      render(EmployeeFormDrawer, {open: true, onClose: vi.fn(), onSaved: vi.fn()});
      expect(mockGet).toHaveBeenCalledWith('/trucks?per_page=100&page=1');
    });

    it('hides the truck field when role is changed away from driver', async () => {
      mockGet.mockResolvedValue([]);
      const {getByLabelText, queryByLabelText} = render(EmployeeFormDrawer, {
        open: true,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      await fireEvent.change(getByLabelText('Rôle'), {target: {value: 'mechanic'}});
      expect(queryByLabelText('Camion assigné')).not.toBeInTheDocument();
    });

    it('calls onClose when clicking the overlay', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByRole} = render(EmployeeFormDrawer, {open: true, onClose, onSaved: vi.fn()});
      await fireEvent.click(getByRole('presentation', {hidden: true}));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking the close button', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByLabelText} = render(EmployeeFormDrawer, {open: true, onClose, onSaved: vi.fn()});
      await fireEvent.click(getByLabelText('Fermer'));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when pressing Escape', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      render(EmployeeFormDrawer, {open: true, onClose, onSaved: vi.fn()});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking Annuler', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByText} = render(EmployeeFormDrawer, {open: true, onClose, onSaved: vi.fn()});
      await fireEvent.click(getByText('Annuler'));
      expect(onClose).toHaveBeenCalled();
    });

    describe('validation', () => {
      it('shows required errors when submitting an empty form', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose: vi.fn(),
          onSaved: vi.fn(),
        });
        await fireEvent.click(getByText("Créer l'employé"));
        await waitFor(() => expect(getByText('Le prénom est requis')).toBeInTheDocument());
        expect(getByText('Le nom est requis')).toBeInTheDocument();
      });

      it('does not call createEmployee when required fields are missing', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose: vi.fn(),
          onSaved: vi.fn(),
        });
        await fireEvent.click(getByText("Créer l'employé"));
        await waitFor(() => expect(getByText('Le prénom est requis')).toBeInTheDocument());
        expect(mockPost).not.toHaveBeenCalled();
      });
    });

    describe('submission', () => {
      it('submits only the required fields when optional fields are blank', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeEmployee());
        const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose: vi.fn(),
          onSaved: vi.fn(),
        });
        await fillRequiredFields(getByLabelText);
        await fireEvent.click(getByText("Créer l'employé"));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith('/employees/create', {
          firstName: 'Mamadou',
          lastName: 'Diallo',
          role: 'driver',
          status: 'active',
          truckId: null,
        });
      });

      it('includes optional fields when filled in', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeEmployee());
        const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose: vi.fn(),
          onSaved: vi.fn(),
        });
        await fillRequiredFields(getByLabelText);
        await fireEvent.input(getByLabelText('Téléphone'), {target: {value: '+224 620 000 000'}});
        await fireEvent.input(getByLabelText('Adresse'), {
          target: {value: '12 Rue du Port, Conakry'},
        });
        await fireEvent.input(getByLabelText("Date d'embauche"), {target: {value: '2024-03-01'}});
        await fireEvent.click(getByText("Créer l'employé"));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/employees/create',
          expect.objectContaining({
            phoneNumber: '+224 620 000 000',
            address: '12 Rue du Port, Conakry',
            hireDate: '2024-03-01',
          })
        );
      });

      it('includes the selected truckId when role is driver', async () => {
        mockGet.mockResolvedValue([makeTruck({id: 5, plateNumber: 'GN-3310-C'})]);
        mockPost.mockResolvedValue(makeEmployee());
        const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose: vi.fn(),
          onSaved: vi.fn(),
        });
        await fillRequiredFields(getByLabelText);
        await waitFor(() => expect(getByLabelText('Camion assigné')).toBeInTheDocument());
        await fireEvent.change(getByLabelText('Camion assigné'), {target: {value: '5'}});
        await fireEvent.click(getByText("Créer l'employé"));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/employees/create',
          expect.objectContaining({truckId: 5})
        );
      });

      it('sends truckId as null when role is not driver', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeEmployee());
        const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose: vi.fn(),
          onSaved: vi.fn(),
        });
        await fillRequiredFields(getByLabelText);
        await fireEvent.change(getByLabelText('Rôle'), {target: {value: 'mechanic'}});
        await fireEvent.click(getByText("Créer l'employé"));

        await waitFor(() => expect(mockPost).toHaveBeenCalled());
        expect(mockPost).toHaveBeenCalledWith(
          '/employees/create',
          expect.objectContaining({role: 'mechanic', truckId: null})
        );
      });

      it('calls onSaved and onClose on success', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockResolvedValue(makeEmployee());
        const onClose = vi.fn();
        const onSaved = vi.fn();
        const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose,
          onSaved,
        });
        await fillRequiredFields(getByLabelText);
        await fireEvent.click(getByText("Créer l'employé"));

        await waitFor(() => expect(onSaved).toHaveBeenCalled());
        expect(onClose).toHaveBeenCalled();
      });

      it('shows the API error and does not close on failure', async () => {
        mockGet.mockResolvedValue([]);
        mockPost.mockRejectedValue(new Error('Erreur serveur'));
        const onClose = vi.fn();
        const onSaved = vi.fn();
        const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
          open: true,
          onClose,
          onSaved,
        });
        await fillRequiredFields(getByLabelText);
        await fireEvent.click(getByText("Créer l'employé"));

        await waitFor(() => expect(getByText('Erreur serveur')).toBeInTheDocument());
        expect(onSaved).not.toHaveBeenCalled();
        expect(onClose).not.toHaveBeenCalled();
      });
    });
  });

  describe('edit mode (employee prop provided)', () => {
    const EMPLOYEE = makeEmployee({
      id: 7,
      firstName: 'Ibra',
      lastName: 'Sow',
      phoneNumber: '+224 622 333 444',
      address: '45 Avenue de la République, Kindia',
      hireDate: '2023-09-01',
      role: 'driver',
      status: 'on_leave',
      assignedTruck: {id: 5, plateNumber: 'GN-3310-C'},
    });

    it('renders the "Modifier l\'employé" title', () => {
      mockGet.mockResolvedValue([]);
      const {getByText} = render(EmployeeFormDrawer, {
        open: true,
        employee: EMPLOYEE,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(getByText("Modifier l'employé")).toBeInTheDocument();
    });

    it('pre-fills the fields with the employee data', async () => {
      mockGet.mockResolvedValue([makeTruck({id: 5, plateNumber: 'GN-3310-C'})]);
      const {getByLabelText} = render(EmployeeFormDrawer, {
        open: true,
        employee: EMPLOYEE,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(getByLabelText('Prénom')).toHaveValue('Ibra');
      expect(getByLabelText('Nom')).toHaveValue('Sow');
      expect(getByLabelText('Téléphone')).toHaveValue('+224 622 333 444');
      expect(getByLabelText('Adresse')).toHaveValue('45 Avenue de la République, Kindia');
      expect(getByLabelText("Date d'embauche")).toHaveValue('2023-09-01');
      expect(getByLabelText('Rôle')).toHaveValue('driver');
      expect(getByLabelText('Statut')).toHaveValue('on_leave');
      await waitFor(() => expect(getByLabelText('Camion assigné')).toHaveValue('5'));
    });

    it('submits the "Enregistrer" button label', () => {
      mockGet.mockResolvedValue([]);
      const {getByText} = render(EmployeeFormDrawer, {
        open: true,
        employee: EMPLOYEE,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      expect(getByText('Enregistrer')).toBeInTheDocument();
    });

    it('calls updateEmployee with the employee id on submit', async () => {
      mockGet.mockResolvedValue([makeTruck({id: 5, plateNumber: 'GN-3310-C'})]);
      mockPatch.mockResolvedValue(EMPLOYEE);
      const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
        open: true,
        employee: EMPLOYEE,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      await waitFor(() => expect(getByLabelText('Camion assigné')).toHaveValue('5'));
      await fireEvent.click(getByText('Enregistrer'));

      await waitFor(() => expect(mockPatch).toHaveBeenCalled());
      expect(mockPatch).toHaveBeenCalledWith(
        '/employees/7/update',
        expect.objectContaining({firstName: 'Ibra', lastName: 'Sow', truckId: 5})
      );
    });

    it('sends truckId: null when the truck assignment is cleared', async () => {
      mockGet.mockResolvedValue([makeTruck({id: 5, plateNumber: 'GN-3310-C'})]);
      mockPatch.mockResolvedValue(EMPLOYEE);
      const {getByLabelText, getByText} = render(EmployeeFormDrawer, {
        open: true,
        employee: EMPLOYEE,
        onClose: vi.fn(),
        onSaved: vi.fn(),
      });
      await waitFor(() => expect(getByLabelText('Camion assigné')).toHaveValue('5'));
      await fireEvent.change(getByLabelText('Camion assigné'), {target: {value: ''}});
      await fireEvent.click(getByText('Enregistrer'));

      await waitFor(() => expect(mockPatch).toHaveBeenCalled());
      expect(mockPatch).toHaveBeenCalledWith(
        '/employees/7/update',
        expect.objectContaining({truckId: null})
      );
    });

    it('calls onSaved and onClose on success', async () => {
      mockGet.mockResolvedValue([]);
      mockPatch.mockResolvedValue(EMPLOYEE);
      const onClose = vi.fn();
      const onSaved = vi.fn();
      const {getByText} = render(EmployeeFormDrawer, {
        open: true,
        employee: EMPLOYEE,
        onClose,
        onSaved,
      });
      await fireEvent.click(getByText('Enregistrer'));

      await waitFor(() => expect(onSaved).toHaveBeenCalled());
      expect(onClose).toHaveBeenCalled();
    });
  });
});
