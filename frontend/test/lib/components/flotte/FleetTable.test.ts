import {render, fireEvent, waitFor} from '@testing-library/svelte';
import FleetTable from '$lib/components/flotte/FleetTable.svelte';
import type {Truck} from '$lib/types/truck';
import {makeTruck} from '../../../mocks/truck';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, post: mockPost}}));

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
      conformity_certificate_expires_on: null,
      conformity_certificate_days_remaining: 25,
    },
    truck_insurance_days_remaining: 45,
    cargo_insurance_days_remaining: 120,
    technical_inspection_days_remaining: 8,
    operating_permit_days_remaining: 200,
    truck_registration_days_remaining: 330,
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
    truck_insurance_days_remaining: -5,
    cargo_insurance_days_remaining: null,
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
    expect(getByText('Ass. camion')).toBeInTheDocument();
    expect(getByText('Ass. produit')).toBeInTheDocument();
    expect(getByText('Visite tech.')).toBeInTheDocument();
    expect(getByText('Carte de Transport')).toBeInTheDocument();
    expect(getByText('Carte grise')).toBeInTheDocument();
    expect(getByText('Baremage')).toBeInTheDocument();
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

  describe('expiry pills', () => {
    it('shows a green pill with days remaining when more than 60 days remain', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      const pill = await waitFor(() => getByText('dans 120j'));
      expect(pill).toHaveClass('text-dt-green');
    });

    it('shows a yellow pill with days remaining when 15 to 60 days remain', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      const pill = await waitFor(() => getByText('dans 45j'));
      expect(pill).toHaveClass('text-dt-yellow');
    });

    it('shows a red pill with days remaining when fewer than 15 days remain', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      const pill = await waitFor(() => getByText('dans 8j'));
      expect(pill).toHaveClass('text-dt-red');
    });

    it('shows a red Expiré pill when the document has already expired', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      const pill = await waitFor(() => getByText('Expiré'));
      expect(pill).toHaveClass('text-dt-red');
    });

    it('shows a neutral N/A pill when no document is on file', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getAllByText} = render(FleetTable);
      const pills = await waitFor(() => getAllByText('N/A'));
      expect(pills.length).toBeGreaterThan(0);
      expect(pills[0]).toHaveClass('text-dt-text-muted');
    });

    it('renders the truck registration pill', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      const pill = await waitFor(() => getByText('dans 330j'));
      expect(pill).toHaveClass('text-dt-green');
    });

    it("renders the tank's conformity certificate pill", async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      const pill = await waitFor(() => getByText('dans 25j'));
      expect(pill).toHaveClass('text-dt-yellow');
    });

    it('shows N/A for the conformity certificate pill when the truck has no tank', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getAllByText} = render(FleetTable);
      const pills = await waitFor(() => getAllByText('N/A'));
      expect(pills.length).toBeGreaterThan(0);
    });
  });

  describe('add truck drawer', () => {
    it('renders the "Ajouter un camion" button', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      await waitFor(() => expect(getByText('Ajouter un camion')).toBeInTheDocument());
    });

    it('opens the drawer when the button is clicked', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, getAllByText} = render(FleetTable);
      await waitFor(() => expect(getByText('Ajouter un camion')).toBeInTheDocument());
      await fireEvent.click(getByText('Ajouter un camion'));
      expect(getAllByText('Ajouter un camion').length).toBe(2); // button + drawer title
    });

    it('closes the drawer when Annuler is clicked', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, queryByText} = render(FleetTable);
      await waitFor(() => expect(getByText('Ajouter un camion')).toBeInTheDocument());
      await fireEvent.click(getByText('Ajouter un camion'));
      await fireEvent.click(getByText('Annuler'));
      expect(queryByText('Annuler')).not.toBeInTheDocument();
    });

    it('refetches the fleet after a truck is successfully created', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      mockPost.mockResolvedValue(makeTruck());
      const truckCalls = () =>
        mockGet.mock.calls.filter(([url]) => url.startsWith('/trucks')).length;
      const {getByText, getAllByLabelText, getByLabelText} = render(FleetTable);
      await waitFor(() => expect(truckCalls()).toBe(1));

      await fireEvent.click(getByText('Ajouter un camion'));
      await fireEvent.input(getAllByLabelText('Immatriculation')[0], {target: {value: 'NEW-001'}});
      await fireEvent.input(getAllByLabelText('Modèle')[0], {target: {value: 'FH'}});
      await fireEvent.input(getAllByLabelText('Année')[0], {target: {value: '2024'}});
      await fireEvent.input(getAllByLabelText('Immatriculation')[1], {target: {value: 'TK-001'}});
      await fireEvent.input(getByLabelText('Capacité (L)'), {target: {value: '30000'}});
      await fireEvent.click(getByText('Créer le camion'));

      await waitFor(() => expect(mockPost).toHaveBeenCalled());
      await waitFor(() => expect(truckCalls()).toBe(2));
    });
  });
});
