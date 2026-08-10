import {render, waitFor, fireEvent} from '@testing-library/svelte';
import MaintenanceList from '$lib/components/maintenance/MaintenanceList.svelte';
import {makeMaintenance} from '../../../mocks/maintenance';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

const page = (items: ReturnType<typeof makeMaintenance>[]) => ({
  items,
  nextCursor: null,
  hasMore: false,
});

describe('MaintenanceList', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the column headers', async () => {
    mockGet.mockReturnValue(new Promise(() => {}));
    const {getByText} = render(MaintenanceList);
    expect(getByText('Camion')).toBeInTheDocument();
    expect(getByText('Type')).toBeInTheDocument();
    expect(getByText('Description')).toBeInTheDocument();
    expect(getByText('Technicien')).toBeInTheDocument();
    expect(getByText('Date')).toBeInTheDocument();
    expect(getByText('Durée (h)')).toBeInTheDocument();
    expect(getByText('Coût pièces')).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
  });

  it('renders the truck plate number and kind for each row', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({truck: {id: 1, plateNumber: 'GN-3310-C'}})]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
    expect(getByText('Entretien courant')).toBeInTheDocument();
  });

  it('renders the description, falling back to a dash when absent', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({description: 'Changement pneus'})]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('Changement pneus')).toBeInTheDocument());
  });

  it('shows the "En cours" pill for an ongoing (started) maintenance', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({state: 'started'})]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('En cours')).toBeInTheDocument());
  });

  it('shows the "Terminé" pill for a completed maintenance', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({state: 'completed'})]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('Terminé')).toBeInTheDocument());
  });

  it('shows the technician name when present', async () => {
    mockGet.mockResolvedValue(
      page([makeMaintenance({technician: {id: 1, name: 'Mamadou Diallo'}})])
    );
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
  });

  it('falls back to a dash when there is no technician', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({technician: null})]));
    const {getAllByText} = render(MaintenanceList);
    await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
  });

  it('shows the duration in hours when present', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({duration: 6})]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('6')).toBeInTheDocument());
  });

  it('shows the cost formatted in GNF when present', async () => {
    mockGet.mockResolvedValue(page([makeMaintenance({cost: 850_000})]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('850 000 GNF')).toBeInTheDocument());
  });

  it('renders the state filter chips', async () => {
    mockGet.mockResolvedValue(page([]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('Tous')).toBeInTheDocument());
    expect(getByText('En cours')).toBeInTheDocument();
    expect(getByText('Terminés')).toBeInTheDocument();
  });

  it('refetches with the state filter when a chip is clicked', async () => {
    mockGet.mockResolvedValue(page([]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
    await fireEvent.click(getByText('Terminés'));
    await waitFor(() =>
      expect(mockGet).toHaveBeenLastCalledWith('/maintenances?state=completed&limit=50')
    );
  });

  it('renders a search input and refetches with the search param after debounce', async () => {
    vi.useFakeTimers();
    mockGet.mockResolvedValue(page([]));
    const {getByPlaceholderText} = render(MaintenanceList);
    await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
    const input = getByPlaceholderText('Rechercher...');
    await fireEvent.input(input, {target: {value: 'GN-3310'}});
    vi.runAllTimers();
    await waitFor(() =>
      expect(mockGet).toHaveBeenCalledWith('/maintenances?search=GN-3310&limit=50')
    );
    vi.useRealTimers();
  });

  it('shows the empty state when there are no maintenances', async () => {
    mockGet.mockResolvedValue(page([]));
    const {getByText} = render(MaintenanceList);
    await waitFor(() => expect(getByText('Aucun résultat.')).toBeInTheDocument());
  });
});
