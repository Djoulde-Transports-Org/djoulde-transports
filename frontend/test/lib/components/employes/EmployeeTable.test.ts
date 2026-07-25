import {render, waitFor, within} from '@testing-library/svelte';
import EmployeeTable from '$lib/components/employes/EmployeeTable.svelte';
import type {Employee} from '$lib/types/employee';
import {makeEmployee} from '../../../mocks/employee';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

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

  describe('status badges', () => {
    it('shows a green Actif badge for active employees', async () => {
      mockGet.mockResolvedValue(EMPLOYEES);
      const {container} = render(EmployeeTable);
      await waitFor(() => {
        const tbody = within(container.querySelector('tbody') as HTMLElement);
        expect(tbody.getByText('Actif')).toHaveClass('text-dt-green');
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
});
