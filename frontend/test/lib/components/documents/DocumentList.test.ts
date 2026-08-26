import {render, waitFor, fireEvent} from '@testing-library/svelte';
import DocumentList from '$lib/components/documents/DocumentList.svelte';
import {makeDocument} from '../../../mocks/document';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

const page = (items: ReturnType<typeof makeDocument>[]) => ({
  items,
  nextCursor: null,
  hasMore: false,
});

describe('DocumentList', () => {
  afterEach(() => vi.clearAllMocks());

  it('renders the column headers', async () => {
    mockGet.mockReturnValue(new Promise(() => {}));
    const {getByText} = render(DocumentList);
    expect(getByText('Nom')).toBeInTheDocument();
    expect(getByText('N°')).toBeInTheDocument();
    expect(getByText('Catégorie')).toBeInTheDocument();
    expect(getByText('Lié à')).toBeInTheDocument();
    expect(getByText('Émis le')).toBeInTheDocument();
    expect(getByText('Ajouté le')).toBeInTheDocument();
    expect(getByText('Expire le')).toBeInTheDocument();
    expect(getByText('Ajouté par')).toBeInTheDocument();
    expect(getByText('Fichier joint')).toBeInTheDocument();
  });

  it('renders the document number', async () => {
    mockGet.mockResolvedValue(page([makeDocument({number: 'INS-2026-04'})]));
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('INS-2026-04')).toBeInTheDocument());
  });

  it('formats the issued-on date', async () => {
    mockGet.mockResolvedValue(page([makeDocument({issuedOn: '2026-02-10'})]));
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('10/02/2026')).toBeInTheDocument());
  });

  it('shows a check icon when a file is attached, a dash otherwise', async () => {
    mockGet.mockResolvedValue(
      page([makeDocument({id: 1, fileAttached: true}), makeDocument({id: 2, fileAttached: false})])
    );
    const {container, getAllByText} = render(DocumentList);
    await waitFor(() => expect(container.querySelectorAll('svg.text-dt-green')).toHaveLength(1));
    expect(getAllByText('—').length).toBeGreaterThan(0);
  });

  it('renders the document title, category and linked entity for each row', async () => {
    mockGet.mockResolvedValue(
      page([
        makeDocument({
          title: 'Assurance camion 2026',
          docType: 'truck_insurance',
          documentableType: 'Truck',
          documentableId: 42,
        }),
      ])
    );
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('Assurance camion 2026')).toBeInTheDocument());
    expect(getByText('Assurance camion')).toBeInTheDocument();
    expect(getByText('Camion #42')).toBeInTheDocument();
  });

  it('renders the linked entity label for a document attached to an employee', async () => {
    mockGet.mockResolvedValue(
      page([
        makeDocument({
          title: 'Permis de conduire',
          docType: 'driver_license',
          documentableType: 'Employee',
          documentableId: 7,
        }),
      ])
    );
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('Employé #7')).toBeInTheDocument());
  });

  it('formats the upload date and expiry date', async () => {
    mockGet.mockResolvedValue(
      page([makeDocument({createdAt: '2026-06-25T10:00:00Z', expiresOn: '2027-03-15'})])
    );
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('25/06/2026')).toBeInTheDocument());
    expect(getByText('15/03/2027')).toBeInTheDocument();
  });

  it('shows the uploader name in the "added by" column', async () => {
    mockGet.mockResolvedValue(page([makeDocument({uploadedBy: {id: 3, name: 'Mamadou Diallo'}})]));
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('Mamadou Diallo')).toBeInTheDocument());
  });

  it('shows a dash when the document has no expiry date or uploader', async () => {
    mockGet.mockResolvedValue(page([makeDocument({expiresOn: null, uploadedBy: null})]));
    const {getAllByText} = render(DocumentList);
    await waitFor(() => expect(getAllByText('—').length).toBeGreaterThan(0));
  });

  it('renders the linked-entity filter chips', async () => {
    mockGet.mockResolvedValue(page([]));
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('Tous')).toBeInTheDocument());
    expect(getByText('Camions')).toBeInTheDocument();
    expect(getByText('Citernes')).toBeInTheDocument();
    expect(getByText('Trajets')).toBeInTheDocument();
    expect(getByText('Maintenance')).toBeInTheDocument();
  });

  it('refetches with the documentable_type filter when a chip is clicked', async () => {
    mockGet.mockResolvedValue(page([]));
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
    await fireEvent.click(getByText('Citernes'));
    await waitFor(() =>
      expect(mockGet).toHaveBeenLastCalledWith('/documents?documentable_type=Tank&limit=50')
    );
  });

  it('renders a search input and refetches with the search param after debounce', async () => {
    vi.useFakeTimers();
    mockGet.mockResolvedValue(page([]));
    const {getByPlaceholderText} = render(DocumentList);
    await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
    const input = getByPlaceholderText('Rechercher...');
    await fireEvent.input(input, {target: {value: 'Assurance'}});
    vi.runAllTimers();
    await waitFor(() =>
      expect(mockGet).toHaveBeenCalledWith('/documents?search=Assurance&limit=50')
    );
    vi.useRealTimers();
  });

  it('shows the empty state when there are no documents', async () => {
    mockGet.mockResolvedValue(page([]));
    const {getByText} = render(DocumentList);
    await waitFor(() => expect(getByText('Aucun résultat.')).toBeInTheDocument());
  });

  describe('new document drawer', () => {
    it('renders the "+ Ajouter un document" action button', async () => {
      mockGet.mockResolvedValue(page([]));
      const {getByText} = render(DocumentList);
      await waitFor(() => expect(getByText('+ Ajouter un document')).toBeInTheDocument());
    });

    it('opens the drawer when the action button is clicked', async () => {
      mockGet.mockResolvedValue(page([]));
      const {getByText} = render(DocumentList);
      await waitFor(() => expect(getByText('+ Ajouter un document')).toBeInTheDocument());
      await fireEvent.click(getByText('+ Ajouter un document'));
      expect(getByText('Ajouter un document')).toBeInTheDocument();
    });
  });
});
