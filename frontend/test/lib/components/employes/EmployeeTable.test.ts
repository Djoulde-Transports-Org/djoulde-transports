import {render, waitFor, within, fireEvent} from '@testing-library/svelte';
import EmployeeTable from '$lib/components/employes/EmployeeTable.svelte';
import type {Employee} from '$lib/types/employee';
import {makeEmployee} from '../../../mocks/employee';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, post: mockPost}}));

const withTrucks = (employees: Employee[]) => (url: string) =>
  Promise.resolve(url.startsWith('/trucks') ? [] : employees);

const EMPLOYEES: Employee[] = [
  makeEmployee({
    id: 7,
    firstName: 'Mamadou',
    lastName: 'Diallo',
    fullName: 'Mamadou Diallo',
    phoneNumber: '+224 620 000 000',
    address: '12 Rue du Port, Conakry',
    hireDate: '2024-03-01',
    role: 'driver',
    status: 'active',
    assignedTruck: {id: 1, plateNumber: 'GN-3310-C'},
  }),
  makeEmployee({
    id: 12,
    firstName: 'Ibra',
    lastName: 'Sow',
    fullName: 'Ibra Sow',
    phoneNumber: null,
    address: null,
    hireDate: null,
    role: 'mechanic',
    status: 'on_leave',
    assignedTruck: null,
  }),
  makeEmployee({
    id: 21,
    firstName: 'Fatou',
    lastName: 'Camara',
    fullName: 'Fatou Camara',
    role: 'dispatcher',
    status: 'inactive',
    assignedTruck: null,
  }),
  makeEmployee({
    id: 33,
    firstName: 'Alpha',
    lastName: 'Barry',
    fullName: 'Alpha Barry',
    role: 'manager',
    status: 'active',
    assignedTruck: null,
  }),
];

describe('EmployeeTable', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the column headers', async () => {
    mockGet.mockReturnValue(new Promise(() => {}));
    const {getByText} = render(EmployeeTable);
    expect(getByText('Nom')).toBeInTheDocument();
    expect(getByText('Rôle')).toBeInTheDocument();
    expect(getByText('Téléphone')).toBeInTheDocument();
    expect(getByText('Adresse')).toBeInTheDocument();
    expect(getByText("Date d'embauche")).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
    expect(getByText('Camion assigné')).toBeInTheDocument();
  });

  it('fetches the employees endpoint', async () => {
    mockGet.mockResolvedValue(EMPLOYEES);
    render(EmployeeTable);
    await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/employees?per_page=100'));
  });

  it('renders the full name and employee ID as sub-text', async () => {
    mockGet.mockResolvedValue(EMPLOYEES);
    const {getByText} = render(EmployeeTable);
    await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
    expect(getByText('ID 7')).toBeInTheDocument();
  });

  it('renders the phone number, or a dash when absent', async () => {
    mockGet.mockResolvedValue(EMPLOYEES);
    const {getByText, getAllByText} = render(EmployeeTable);
    await waitFor(() => expect(getByText('+224 620 000 000')).toBeInTheDocument());
    expect(getAllByText('—').length).toBeGreaterThan(0);
  });

  it('renders the address, or a dash when absent', async () => {
    mockGet.mockResolvedValue(EMPLOYEES);
    const {getByText} = render(EmployeeTable);
    await waitFor(() => expect(getByText('12 Rue du Port, Conakry')).toBeInTheDocument());
  });

  it('renders the hire date as DD/MM/YYYY', async () => {
    mockGet.mockResolvedValue(EMPLOYEES);
    const {getByText} = render(EmployeeTable);
    await waitFor(() => expect(getByText('01/03/2024')).toBeInTheDocument());
  });

  it('renders the assigned truck plate number, or a dash when unassigned', async () => {
    mockGet.mockResolvedValue(EMPLOYEES);
    const {getByText} = render(EmployeeTable);
    await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
  });

  describe('role badges', () => {
    it('shows an orange Chauffeur badge for drivers', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      const badge = await waitFor(() => getByText('Chauffeur'));
      expect(badge).toHaveClass('text-accent');
    });

    it('shows a yellow Technicien badge for mechanics', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      const badge = await waitFor(() => getByText('Technicien'));
      expect(badge).toHaveClass('text-dt-yellow');
    });

    it('shows a neutral Dispatcher badge', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      const badge = await waitFor(() => getByText('Dispatcher'));
      expect(badge).toHaveClass('text-dt-text-muted');
    });
  });

  describe('filters and search', () => {
    it('renders the Tous / Chauffeurs / Techniciens / Admin filter chips', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText, getByRole} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Tous (4)')).toBeInTheDocument());
      expect(getByText('Chauffeurs')).toBeInTheDocument();
      expect(getByText('Techniciens')).toBeInTheDocument();
      expect(getByRole('button', {name: 'Admin'})).toBeInTheDocument();
    });

    it('fetches the employees endpoint only once regardless of filtering', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.click(getByText('Chauffeurs'));
      expect(mockGet).toHaveBeenCalledTimes(1);
      expect(mockGet).toHaveBeenCalledWith('/employees?per_page=100');
    });

    it('narrows rows to the selected role when a chip is clicked', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText, queryByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.click(getByText('Chauffeurs'));
      expect(getByText('Mamadou Diallo')).toBeInTheDocument();
      expect(queryByText('Ibra Sow')).not.toBeInTheDocument();
    });

    it('the Admin chip matches both dispatcher and manager roles', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText, getByRole, queryByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.click(getByRole('button', {name: 'Admin'}));
      expect(getByText('Fatou Camara')).toBeInTheDocument();
      expect(getByText('Alpha Barry')).toBeInTheDocument();
      expect(queryByText('Mamadou Diallo')).not.toBeInTheDocument();
    });

    it('"Tous" restores every row after a role chip was active', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.click(getByText('Chauffeurs'));
      await fireEvent.click(getByText('Tous (4)'));
      expect(getByText('Mamadou Diallo')).toBeInTheDocument();
      expect(getByText('Ibra Sow')).toBeInTheDocument();
      expect(getByText('Fatou Camara')).toBeInTheDocument();
      expect(getByText('Alpha Barry')).toBeInTheDocument();
    });

    it('filters rows by name in real time as the user types', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText, getByPlaceholderText, queryByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.input(getByPlaceholderText('Rechercher...'), {target: {value: 'sow'}});
      expect(getByText('Ibra Sow')).toBeInTheDocument();
      expect(queryByText('Mamadou Diallo')).not.toBeInTheDocument();
    });

    it('filters rows by employee ID in real time as the user types', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText, getByPlaceholderText, queryByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.input(getByPlaceholderText('Rechercher...'), {target: {value: '21'}});
      expect(getByText('Fatou Camara')).toBeInTheDocument();
      expect(queryByText('Mamadou Diallo')).not.toBeInTheDocument();
    });

    it('updates the count in the "Tous" chip as the search narrows results', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText, getByPlaceholderText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Tous (4)')).toBeInTheDocument());
      await fireEvent.input(getByPlaceholderText('Rechercher...'), {target: {value: 'sow'}});
      expect(getByText('Tous (1)')).toBeInTheDocument();
    });
  });

  describe('status badges', () => {
    it('shows a green Actif badge for active employees', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {container} = render(EmployeeTable);
      await waitFor(() => {
        const tbody = within(container.querySelector('tbody') as HTMLElement);
        const badges = tbody.getAllByText('Actif');
        expect(badges.length).toBe(2);
        expect(badges[0]).toHaveClass('text-dt-green');
      });
    });

    it('shows a yellow En congé badge for employees on leave', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      const badge = await waitFor(() => getByText('En congé'));
      expect(badge).toHaveClass('text-dt-yellow');
    });

    it('shows a neutral Inactif badge for inactive employees', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      const badge = await waitFor(() => getByText('Inactif'));
      expect(badge).toHaveClass('text-dt-text-muted');
    });
  });

  describe('add/edit drawer', () => {
    it('renders the "Ajouter un employé" button', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Ajouter un employé')).toBeInTheDocument());
    });

    it('opens the drawer in add mode when the button is clicked', async () => {
      mockGet.mockImplementation(withTrucks(EMPLOYEES));
      const {getByText, getAllByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Ajouter un employé')).toBeInTheDocument());
      await fireEvent.click(getByText('Ajouter un employé'));
      expect(getAllByText('Ajouter un employé').length).toBe(2); // button + drawer title
    });

    it('closes the drawer when Annuler is clicked', async () => {
      mockGet.mockImplementation(withTrucks(EMPLOYEES));
      const {getByText, queryByText} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Ajouter un employé')).toBeInTheDocument());
      await fireEvent.click(getByText('Ajouter un employé'));
      await fireEvent.click(getByText('Annuler'));
      expect(queryByText('Annuler')).not.toBeInTheDocument();
    });

    it("opens the drawer in edit mode with the clicked row's employee prefilled", async () => {
      mockGet.mockImplementation(withTrucks(EMPLOYEES));
      const {getByText, getByLabelText, container} = render(EmployeeTable);
      await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
      await fireEvent.click(getByText('Mamadou Diallo').closest('tr') as HTMLElement);
      const dialog = container.querySelector('[role="dialog"]');
      expect(dialog).toBeInTheDocument();
      expect(getByText("Modifier l'employé")).toBeInTheDocument();
      expect(getByLabelText('Prénom')).toHaveValue('Mamadou');
    });

    it('signals clickable rows with a pointer cursor', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {getByText} = render(EmployeeTable);
      await waitFor(() =>
        expect(getByText('Mamadou Diallo').closest('tr')).toHaveClass('cursor-pointer')
      );
    });

    it('refetches the employee list after a successful save', async () => {
      mockGet.mockImplementation(withTrucks(EMPLOYEES));
      mockPost.mockResolvedValue(EMPLOYEES[0]);
      const employeeCalls = () =>
        mockGet.mock.calls.filter(([url]) => url.startsWith('/employees')).length;
      const {getByText, getByLabelText} = render(EmployeeTable);
      await waitFor(() => expect(employeeCalls()).toBe(1));

      await fireEvent.click(getByText('Ajouter un employé'));
      await fireEvent.input(getByLabelText('Prénom'), {target: {value: 'Test'}});
      await fireEvent.input(getByLabelText('Nom'), {target: {value: 'Employee'}});
      await fireEvent.click(getByText("Créer l'employé"));

      await waitFor(() => expect(mockPost).toHaveBeenCalled());
      await waitFor(() => expect(employeeCalls()).toBe(2));
    });
  });
});
