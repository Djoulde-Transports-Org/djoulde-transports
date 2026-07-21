import {render, waitFor} from '@testing-library/svelte';
import FleetTable from '$lib/components/flotte/FleetTable.svelte';
import type {Truck} from '$lib/types/truck';
import {makeTruck} from '../../../mocks/truck';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

const TRUCKS: Truck[] = [
  makeTruck({
    id: 1,
    plate_number: 'GN-3310-C',
    make: 'Volvo',
    model: 'FH',
    year: 2019,
    status: 'on_trip',
    last_oil_change_on: '2025-06-12',
    tank: {
      id: 1,
      truck_id: 1,
      plate_number: 'TC-041',
      vin: null,
      make: null,
      model: null,
      year: null,
      capacity: 33_000,
      status: 'active',
    },
  }),
  makeTruck({
    id: 2,
    plate_number: 'GN-1892-B',
    make: null,
    model: null,
    year: null,
    status: 'in_maintenance',
    last_oil_change_on: null,
    tank: null,
  }),
  makeTruck({
    id: 3,
    plate_number: 'GN-5521-G',
    make: 'Renault',
    model: 'T',
    year: 2020,
    status: 'ready',
    last_oil_change_on: '2025-06-08',
    tank: null,
  }),
];

describe('FleetTable', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the column headers', async () => {
    mockGet.mockReturnValue(new Promise(() => {}));
    const {getByText} = render(FleetTable);
    expect(getByText('Immatriculation')).toBeInTheDocument();
    expect(getByText('Modèle')).toBeInTheDocument();
    expect(getByText('Citerne')).toBeInTheDocument();
    expect(getByText('Statut')).toBeInTheDocument();
    expect(getByText('Dernière vidange')).toBeInTheDocument();
  });

  it('renders the plate number', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
  });

  it('renders make, model and year combined', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('Volvo FH · 2019')).toBeInTheDocument());
  });

  it('renders — for the model column when make, model and year are all missing', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getAllByText} = render(FleetTable);
    await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
  });

  it('renders the tank plate and capacity', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('TC-041 · 33 000 L')).toBeInTheDocument());
  });

  it('shows En route badge for on_trip trucks', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('En route')).toBeInTheDocument());
  });

  it('shows Maintenance badge for in_maintenance trucks', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('Maintenance')).toBeInTheDocument());
  });

  it('shows Prêt badge for ready trucks', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('Prêt')).toBeInTheDocument());
  });

  it('renders the last oil change date as DD/MM/YYYY', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('12/06/2025')).toBeInTheDocument());
  });

  it('signals clickable rows with a pointer cursor', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {getByText} = render(FleetTable);
    await waitFor(() => expect(getByText('GN-3310-C').closest('tr')).toHaveClass('cursor-pointer'));
  });
});
