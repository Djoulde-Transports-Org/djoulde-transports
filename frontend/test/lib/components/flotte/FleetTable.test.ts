import {render, waitFor, within, fireEvent} from '@testing-library/svelte';
import FleetTable from '$lib/components/flotte/FleetTable.svelte';
import type {Truck} from '$lib/types/truck';
import {makeTruck} from '../../../mocks/truck';

const mockGet = vi.hoisted(() => vi.fn());
const mockPost = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, post: mockPost}}));

const TRUCKS: Truck[] = [
  makeTruck({
    id: 1,
    plateNumber: 'GN-3310-C',
    make: 'Volvo',
    model: 'FH',
    year: 2019,
    status: 'on_trip',
    lastOilChangeOn: '2025-06-12',
    tank: {
      id: 1,
      truckId: 1,
      plateNumber: 'TC-041',
      vin: null,
      make: null,
      model: null,
      year: null,
      capacity: 33_000,
      status: 'active',
      conformityCertificateExpiresOn: null,
      conformityCertificateDaysRemaining: 25,
    },
    truckInsuranceDaysRemaining: 45,
    cargoInsuranceDaysRemaining: 120,
    technicalInspectionDaysRemaining: 8,
    operatingPermitDaysRemaining: 200,
    truckRegistrationDaysRemaining: 330,
  }),
  makeTruck({
    id: 2,
    plateNumber: 'GN-1892-B',
    make: null,
    model: null,
    year: null,
    status: 'in_maintenance',
    lastOilChangeOn: null,
    tank: null,
    truckInsuranceDaysRemaining: -5,
    cargoInsuranceDaysRemaining: null,
  }),
  makeTruck({
    id: 3,
    plateNumber: 'GN-5521-G',
    make: 'Renault',
    model: 'T',
    year: 2020,
    status: 'ready',
    lastOilChangeOn: '2025-06-08',
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
    const {container} = render(FleetTable);
    await waitFor(() => {
      const tbody = within(container.querySelector('tbody') as HTMLElement);
      expect(tbody.getByText('En route')).toBeInTheDocument();
    });
  });

  it('shows Maintenance badge for in_maintenance trucks', async () => {
    mockGet.mockResolvedValue(TRUCKS);
    const {container} = render(FleetTable);
    await waitFor(() => {
      const tbody = within(container.querySelector('tbody') as HTMLElement);
      expect(tbody.getByText('Maintenance')).toBeInTheDocument();
    });
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

  describe('filters and search', () => {
    it('renders the Tous / En route / Prêts / Maintenance filter chips', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      await waitFor(() => expect(getByText('Tous')).toBeInTheDocument());
      expect(getByText('Prêts')).toBeInTheDocument();
    });

    it('fetches the trucks endpoint only once regardless of filtering', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.click(getByText('Prêts'));
      expect(mockGet).toHaveBeenCalledTimes(1);
      expect(mockGet).toHaveBeenCalledWith('/trucks?per_page=100');
    });

    it('narrows rows to the selected status when a chip is clicked', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, queryByText, container} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.click(getByText('Prêts'));
      const tbody = within(container.querySelector('tbody') as HTMLElement);
      expect(tbody.getByText('GN-5521-G')).toBeInTheDocument();
      expect(queryByText('GN-3310-C')).not.toBeInTheDocument();
      expect(queryByText('GN-1892-B')).not.toBeInTheDocument();
    });

    it('"Tous" restores every row after a status chip was active', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.click(getByText('Prêts'));
      await fireEvent.click(getByText('Tous'));
      expect(getByText('GN-3310-C')).toBeInTheDocument();
      expect(getByText('GN-1892-B')).toBeInTheDocument();
      expect(getByText('GN-5521-G')).toBeInTheDocument();
    });

    it('filters rows by plate number in real time as the user types', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, getByPlaceholderText, queryByText} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.input(getByPlaceholderText('Rechercher...'), {target: {value: '3310'}});
      expect(getByText('GN-3310-C')).toBeInTheDocument();
      expect(queryByText('GN-1892-B')).not.toBeInTheDocument();
    });

    it('filters rows by model in real time as the user types', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, getByPlaceholderText, queryByText} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.input(getByPlaceholderText('Rechercher...'), {target: {value: 'fh'}});
      expect(getByText('GN-3310-C')).toBeInTheDocument();
      expect(queryByText('GN-5521-G')).not.toBeInTheDocument();
    });
  });

  describe('truck detail drawer', () => {
    it('does not show the drawer before a row is clicked', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, container} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      expect(container.querySelector('[role="dialog"]')).not.toBeInTheDocument();
    });

    it("opens the drawer with the clicked row's truck when a row is clicked", async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, container} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.click(getByText('GN-3310-C').closest('tr') as HTMLElement);
      const dialog = container.querySelector('[role="dialog"]');
      expect(dialog).toBeInTheDocument();
      expect(within(dialog as HTMLElement).getByText('GN-3310-C')).toBeInTheDocument();
      expect(within(dialog as HTMLElement).getByText('Volvo FH · 2019')).toBeInTheDocument();
    });

    it('closes the drawer when its close button is clicked', async () => {
      mockGet.mockResolvedValue(TRUCKS);
      const {getByText, getByLabelText, container} = render(FleetTable);
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
      await fireEvent.click(getByText('GN-3310-C').closest('tr') as HTMLElement);
      await fireEvent.click(getByLabelText('Fermer'));
      expect(container.querySelector('[role="dialog"]')).not.toBeInTheDocument();
    });
  });
});
