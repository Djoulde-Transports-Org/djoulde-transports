import {render, fireEvent, waitFor} from '@testing-library/svelte';
import {createRawSnippet} from 'svelte';
import DataTable from '$lib/components/common/DataTable.svelte';

const mockGet = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet}}));

vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/stores', () => ({page: {subscribe: vi.fn()}}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$app/paths', () => ({resolve: (p: string) => p}));

const COLUMNS = [
  {key: 'id', label: 'ID'},
  {key: 'name', label: 'Nom'},
];

const ROWS = [
  {id: 1, name: 'Alice'},
  {id: 2, name: 'Bob'},
];

describe('DataTable', () => {
  afterEach(() => vi.clearAllMocks());

  describe('loading state', () => {
    it('shows skeleton rows while loading', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {container} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      expect(container.querySelectorAll('.animate-pulse').length).toBe(10); // 5 rows × 2 cols
    });
  });

  describe('loaded state', () => {
    it('renders column headers', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(getByText('ID')).toBeInTheDocument());
      expect(getByText('Nom')).toBeInTheDocument();
    });

    it('renders data rows', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
      expect(getByText('Bob')).toBeInTheDocument();
    });

    it('does not add cursor-pointer to rows by default', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() =>
        expect(getByText('Alice').closest('tr')).not.toHaveClass('cursor-pointer')
      );
    });

    it('adds cursor-pointer to rows when rowClickable is true', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {getByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        rowClickable: true,
      });
      await waitFor(() => expect(getByText('Alice').closest('tr')).toHaveClass('cursor-pointer'));
    });

    it('calls onRowClick with the row data when a row is clicked', async () => {
      mockGet.mockResolvedValue(ROWS);
      const onRowClick = vi.fn();
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS, onRowClick});
      await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
      await fireEvent.click(getByText('Alice').closest('tr') as HTMLElement);
      expect(onRowClick).toHaveBeenCalledWith(ROWS[0]);
    });

    it('does not throw when a row is clicked and onRowClick is not provided', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
      await expect(
        fireEvent.click(getByText('Alice').closest('tr') as HTMLElement)
      ).resolves.not.toThrow();
    });

    it('uses render snippet for cells', async () => {
      const cols = [
        {
          key: 'name',
          label: 'Nom',
          render: createRawSnippet<[unknown, Record<string, unknown>]>((getVal) => ({
            render: () => `<strong>${String(getVal())}</strong>`,
          })),
        },
      ];
      mockGet.mockResolvedValue(ROWS);
      const {container} = render(DataTable, {endpoint: '/employees', columns: cols});
      await waitFor(() => expect(container.querySelector('strong')).toBeInTheDocument());
    });

    it('falls back to empty string for null cell values', async () => {
      mockGet.mockResolvedValue([{id: null, name: null}]);
      const {getAllByRole} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => {
        const cells = getAllByRole('cell');
        expect(cells.some((c) => c.textContent === '')).toBe(true);
      });
    });

    it('calls the endpoint on mount', async () => {
      mockGet.mockResolvedValue(ROWS);
      render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/employees'));
    });
  });

  describe('refresh()', () => {
    it('refetches the current page when called', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {component} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      component.refresh();
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(2));
    });
  });

  describe('empty state', () => {
    it('shows default empty message when rows are empty', async () => {
      mockGet.mockResolvedValue([]);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(getByText('Aucun résultat.')).toBeInTheDocument());
    });

    it('renders custom empty snippet', async () => {
      mockGet.mockResolvedValue([]);
      const emptySnippet = createRawSnippet(() => ({render: () => '<span>Rien ici</span>'}));
      const {getByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        empty: emptySnippet,
      });
      await waitFor(() => expect(getByText('Rien ici')).toBeInTheDocument());
    });
  });

  describe('error state', () => {
    it('shows default error message on API failure', async () => {
      mockGet.mockRejectedValue(new Error('Network error'));
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(getByText('Network error')).toBeInTheDocument());
    });

    it('shows fallback message for non-Error throws', async () => {
      mockGet.mockRejectedValue('oops');
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS});
      await waitFor(() => expect(getByText('Une erreur est survenue.')).toBeInTheDocument());
    });

    it('renders custom error snippet on failure', async () => {
      mockGet.mockRejectedValue(new Error('Oops'));
      const errorSnippet = createRawSnippet<[string]>(() => ({
        render: () => '<span data-testid="custom-err">custom</span>',
      }));
      const {getByTestId} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        error: errorSnippet,
      });
      await waitFor(() => expect(getByTestId('custom-err')).toBeInTheDocument());
    });
  });

  describe('search', () => {
    it('does not render search input when searchParam is not set', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByPlaceholderText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
      });
      expect(queryByPlaceholderText('Rechercher...')).not.toBeInTheDocument();
    });

    it('renders search input when searchParam is set', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByPlaceholderText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        searchParam: 'search',
      });
      expect(getByPlaceholderText('Rechercher...')).toBeInTheDocument();
    });

    it('calls the API with search param after debounce', async () => {
      vi.useFakeTimers();
      mockGet.mockResolvedValue([]);
      const {getByPlaceholderText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        searchParam: 'search',
      });
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      const input = getByPlaceholderText('Rechercher...');
      await fireEvent.input(input, {target: {value: 'Ali'}});
      vi.runAllTimers();
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/employees?search=Ali'));
      vi.useRealTimers();
    });

    it('does not call API immediately on input (debounced)', async () => {
      vi.useFakeTimers();
      mockGet.mockResolvedValue([]);
      const {getByPlaceholderText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        searchParam: 'search',
      });
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      const input = getByPlaceholderText('Rechercher...');
      await fireEvent.input(input, {target: {value: 'X'}});
      expect(mockGet).toHaveBeenCalledTimes(1); // not yet
      vi.useRealTimers();
    });
  });

  describe('filter chips', () => {
    const filters = [
      {key: 'role', label: 'Chauffeur', value: 'driver'},
      {key: 'role', label: 'Mécanicien', value: 'mechanic'},
    ];

    it('renders filter chip labels', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS, filters});
      expect(getByText('Chauffeur')).toBeInTheDocument();
      expect(getByText('Mécanicien')).toBeInTheDocument();
    });

    it('does not render toolbar when no filters, no searchParam, no actions', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByPlaceholderText, queryByRole} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
      });
      expect(queryByPlaceholderText('Rechercher...')).not.toBeInTheDocument();
      expect(queryByRole('button')).not.toBeInTheDocument();
    });

    it('activates a chip on click and refetches with the filter param', async () => {
      mockGet.mockResolvedValue([]);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS, filters});
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      await fireEvent.click(getByText('Chauffeur'));
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/employees?role=driver'));
    });

    it('deactivates a chip on second click and removes the filter param', async () => {
      mockGet.mockResolvedValue([]);
      const {getByText} = render(DataTable, {endpoint: '/employees', columns: COLUMNS, filters});
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(1));
      await fireEvent.click(getByText('Chauffeur'));
      await waitFor(() => expect(mockGet).toHaveBeenCalledTimes(2));
      await fireEvent.click(getByText('Chauffeur'));
      await waitFor(() => expect(mockGet).toHaveBeenLastCalledWith('/employees'));
    });
  });

  describe('clientSide filtering and search', () => {
    const CLIENT_ROWS = [
      {id: 1, name: 'Alice', role: 'driver'},
      {id: 2, name: 'Bob', role: 'mechanic'},
      {id: 3, name: 'Ali', role: 'driver'},
    ];
    const clientFilters = [
      {key: 'role', label: 'Tous', value: ''},
      {key: 'role', label: 'Chauffeur', value: 'driver'},
      {key: 'role', label: 'Mécanicien', value: 'mechanic'},
    ];

    it('fetches the bare endpoint once, ignoring filters and search in the URL', async () => {
      mockGet.mockResolvedValue(CLIENT_ROWS);
      render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        clientSide: true,
        filters: clientFilters,
        searchParam: 'search',
        searchFields: ['name'],
      });
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/employees'));
      expect(mockGet).toHaveBeenCalledTimes(1);
    });

    it('filters already-loaded rows in-memory on chip click without refetching', async () => {
      mockGet.mockResolvedValue(CLIENT_ROWS);
      const {getByText, queryByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        clientSide: true,
        filters: clientFilters,
      });
      await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
      await fireEvent.click(getByText('Chauffeur'));
      expect(getByText('Alice')).toBeInTheDocument();
      expect(getByText('Ali')).toBeInTheDocument();
      expect(queryByText('Bob')).not.toBeInTheDocument();
      expect(mockGet).toHaveBeenCalledTimes(1);
    });

    it('the "Tous" (empty value) chip clears the active filter and is active by default', async () => {
      mockGet.mockResolvedValue(CLIENT_ROWS);
      const {getByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        clientSide: true,
        filters: clientFilters,
      });
      await waitFor(() => expect(getByText('Tous').closest('button')).toHaveClass('text-accent'));
      await fireEvent.click(getByText('Mécanicien'));
      await waitFor(() =>
        expect(getByText('Mécanicien').closest('button')).toHaveClass('text-accent')
      );
      await fireEvent.click(getByText('Tous'));
      await waitFor(() => expect(getByText('Tous').closest('button')).toHaveClass('text-accent'));
      expect(getByText('Alice')).toBeInTheDocument();
      expect(getByText('Bob')).toBeInTheDocument();
    });

    it('filters already-loaded rows in real time on search input across searchFields', async () => {
      mockGet.mockResolvedValue(CLIENT_ROWS);
      const {getByPlaceholderText, getByText, queryByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        clientSide: true,
        searchParam: 'search',
        searchFields: ['name'],
      });
      await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
      const input = getByPlaceholderText('Rechercher...');
      await fireEvent.input(input, {target: {value: 'ali'}});
      expect(getByText('Alice')).toBeInTheDocument();
      expect(getByText('Ali')).toBeInTheDocument();
      expect(queryByText('Bob')).not.toBeInTheDocument();
      expect(mockGet).toHaveBeenCalledTimes(1);
    });

    it('combines an active filter chip and search term', async () => {
      mockGet.mockResolvedValue(CLIENT_ROWS);
      const {getByPlaceholderText, getByText, queryByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        clientSide: true,
        filters: clientFilters,
        searchParam: 'search',
        searchFields: ['name'],
      });
      await waitFor(() => expect(getByText('Alice')).toBeInTheDocument());
      await fireEvent.click(getByText('Chauffeur'));
      const input = getByPlaceholderText('Rechercher...');
      await fireEvent.input(input, {target: {value: 'bob'}});
      expect(queryByText('Bob')).not.toBeInTheDocument();
      expect(queryByText('Alice')).not.toBeInTheDocument();
    });

    it('matches a chip whose value lists several comma-separated options', async () => {
      mockGet.mockResolvedValue(CLIENT_ROWS);
      const {getByText, queryByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        clientSide: true,
        filters: [
          {key: 'role', label: 'Tous', value: ''},
          {key: 'role', label: 'Non-chauffeur', value: 'mechanic,dispatcher'},
        ],
      });
      await waitFor(() => expect(getByText('Bob')).toBeInTheDocument());
      await fireEvent.click(getByText('Non-chauffeur'));
      expect(getByText('Bob')).toBeInTheDocument();
      expect(queryByText('Alice')).not.toBeInTheDocument();
      expect(queryByText('Ali')).not.toBeInTheDocument();
    });

    describe('showAllCount', () => {
      it('does not append a count to the "Tous" chip by default', async () => {
        mockGet.mockResolvedValue(CLIENT_ROWS);
        const {getByText} = render(DataTable, {
          endpoint: '/employees',
          columns: COLUMNS,
          clientSide: true,
          filters: clientFilters,
        });
        await waitFor(() => expect(getByText('Tous')).toBeInTheDocument());
      });

      it('appends the total row count to the "Tous" chip when enabled', async () => {
        mockGet.mockResolvedValue(CLIENT_ROWS);
        const {getByText} = render(DataTable, {
          endpoint: '/employees',
          columns: COLUMNS,
          clientSide: true,
          filters: clientFilters,
          showAllCount: true,
        });
        await waitFor(() => expect(getByText('Tous (3)')).toBeInTheDocument());
      });

      it('updates the count in real time as the search term narrows the rows', async () => {
        mockGet.mockResolvedValue(CLIENT_ROWS);
        const {getByText, getByPlaceholderText} = render(DataTable, {
          endpoint: '/employees',
          columns: COLUMNS,
          clientSide: true,
          filters: clientFilters,
          searchParam: 'search',
          searchFields: ['name'],
          showAllCount: true,
        });
        await waitFor(() => expect(getByText('Tous (3)')).toBeInTheDocument());
        await fireEvent.input(getByPlaceholderText('Rechercher...'), {target: {value: 'ali'}});
        expect(getByText('Tous (2)')).toBeInTheDocument();
      });

      it('does not append a count to non-empty-value chips', async () => {
        mockGet.mockResolvedValue(CLIENT_ROWS);
        const {getByText} = render(DataTable, {
          endpoint: '/employees',
          columns: COLUMNS,
          clientSide: true,
          filters: clientFilters,
          showAllCount: true,
        });
        await waitFor(() => expect(getByText('Chauffeur')).toBeInTheDocument());
      });
    });
  });

  describe('actions snippet', () => {
    it('renders the actions snippet in the toolbar', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const actionsSnippet = createRawSnippet(() => ({
        render: () => '<button>+ Nouveau</button>',
      }));
      const {getByText} = render(DataTable, {
        endpoint: '/employees',
        columns: COLUMNS,
        actions: actionsSnippet,
      });
      expect(getByText('+ Nouveau')).toBeInTheDocument();
    });
  });

  describe('pagination (paginated=false)', () => {
    it('does not show pagination controls by default', async () => {
      mockGet.mockResolvedValue(ROWS);
      const {queryByText} = render(DataTable, {endpoint: '/trips', columns: COLUMNS});
      await waitFor(() => expect(mockGet).toHaveBeenCalled());
      expect(queryByText('Suivant')).not.toBeInTheDocument();
      expect(queryByText('Précédent')).not.toBeInTheDocument();
    });
  });

  describe('pagination (paginated=true)', () => {
    const paginatedResponse = {data: ROWS, nextCursor: 'cur-abc', hasMore: true};
    const lastPageResponse = {data: ROWS, nextCursor: null, hasMore: false};

    it('shows Précédent and Suivant buttons', async () => {
      mockGet.mockResolvedValue(lastPageResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
      });
      await waitFor(() => expect(getByText('Suivant')).toBeInTheDocument());
      expect(getByText('Précédent')).toBeInTheDocument();
    });

    it('Précédent is disabled on the first page', async () => {
      mockGet.mockResolvedValue(paginatedResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
      });
      await waitFor(() => expect(getByText('Précédent').closest('button')).toBeDisabled());
    });

    it('Suivant is disabled when has_more is false', async () => {
      mockGet.mockResolvedValue(lastPageResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
      });
      await waitFor(() => expect(getByText('Suivant').closest('button')).toBeDisabled());
    });

    it('Suivant is enabled when has_more is true', async () => {
      mockGet.mockResolvedValue(paginatedResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
      });
      await waitFor(() => expect(getByText('Suivant').closest('button')).not.toBeDisabled());
    });

    it('clicking Suivant fetches the next page with the cursor and limit', async () => {
      mockGet.mockResolvedValue(paginatedResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
        limit: 10,
      });
      await waitFor(() => expect(getByText('Suivant').closest('button')).not.toBeDisabled());
      await fireEvent.click(getByText('Suivant'));
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/trips?limit=10&after=cur-abc'));
    });

    it('shows page number', async () => {
      mockGet.mockResolvedValue(lastPageResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
      });
      await waitFor(() => expect(getByText('Page 1')).toBeInTheDocument());
    });

    it('clicking Suivant then Précédent returns to page 1', async () => {
      mockGet.mockResolvedValueOnce(paginatedResponse).mockResolvedValue(lastPageResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
      });
      await waitFor(() => expect(getByText('Suivant').closest('button')).not.toBeDisabled());
      await fireEvent.click(getByText('Suivant'));
      await waitFor(() => expect(getByText('Page 2')).toBeInTheDocument());
      await fireEvent.click(getByText('Précédent'));
      await waitFor(() => expect(getByText('Page 1')).toBeInTheDocument());
    });

    it('filter change resets to page 1', async () => {
      const chipFilters = [{key: 'status', label: 'Terminé', value: 'completed'}];
      mockGet.mockResolvedValue(paginatedResponse);
      const {getByText} = render(DataTable, {
        endpoint: '/trips',
        columns: COLUMNS,
        paginated: true,
        filters: chipFilters,
      });
      await waitFor(() => expect(getByText('Suivant').closest('button')).not.toBeDisabled());
      await fireEvent.click(getByText('Suivant'));
      await waitFor(() => expect(getByText('Page 2')).toBeInTheDocument());
      await fireEvent.click(getByText('Terminé'));
      await waitFor(() => expect(getByText('Page 1')).toBeInTheDocument());
    });
  });
});
