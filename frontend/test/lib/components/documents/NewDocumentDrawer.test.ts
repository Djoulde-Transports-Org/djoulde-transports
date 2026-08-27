import {render, fireEvent, waitFor} from '@testing-library/svelte';
import NewDocumentDrawer from '$lib/components/documents/NewDocumentDrawer.svelte';
import {makeTruck} from '../../../mocks/truck';
import {makeTank} from '../../../mocks/tank';
import {makeDocument} from '../../../mocks/document';

const mockGet = vi.hoisted(() => vi.fn());
const mockPostForm = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {get: mockGet, postForm: mockPostForm}}));

const withOptions =
  (byPath: Record<string, unknown[]>) =>
  (url: string): Promise<unknown> => {
    for (const [path, items] of Object.entries(byPath)) {
      if (url.startsWith(path)) return Promise.resolve(items);
    }
    return Promise.resolve([]);
  };

const pdfFile = (name = 'insurance.pdf') => new File(['content'], name, {type: 'application/pdf'});

const formEntries = (form: FormData): Record<string, unknown> => Object.fromEntries(form.entries());

const selectTruckEntity = async (
  getByLabelText: (text: string) => HTMLElement,
  getByText: (text: string) => HTMLElement,
  plate = 'GN-3310-C'
) => {
  await fireEvent.change(getByLabelText('Catégorie'), {target: {value: 'Truck'}});
  const entityInput = getByLabelText('Lié à');
  await fireEvent.focus(entityInput);
  await waitFor(() => expect(getByText(plate)).toBeInTheDocument());
  await fireEvent.mouseDown(getByText(plate));
};

const fillRequiredFields = async (
  getByLabelText: (text: string) => HTMLElement,
  getByText: (text: string) => HTMLElement
) => {
  await fireEvent.input(getByLabelText('Nom du document'), {target: {value: 'Assurance 2026'}});
  await fireEvent.input(getByLabelText('Numéro (optionnel)'), {target: {value: 'INS-2026'}});
  await fireEvent.input(getByLabelText("Date d'émission"), {target: {value: '2026-01-01'}});
  await selectTruckEntity(getByLabelText, getByText);
  await fireEvent.input(getByLabelText('Fichier'), {target: {files: [pdfFile()]}});
  await waitFor(() => expect(getByText('Ajouter le document')).not.toBeDisabled());
};

describe('NewDocumentDrawer', () => {
  afterEach(() => vi.clearAllMocks());

  describe('when closed', () => {
    it('renders nothing', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {queryByRole} = render(NewDocumentDrawer, {
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
      const {getByText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(getByText('Ajouter un document')).toBeInTheDocument();
    });

    it('renders the linked-entity category options', () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByLabelText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      const options = Array.from((getByLabelText('Catégorie') as HTMLSelectElement).options).map(
        (o) => o.textContent
      );
      expect(options).toEqual(
        expect.arrayContaining([
          'Camion',
          'Citerne',
          'Trajet',
          'Maintenance',
          'Employé',
          'Facturation',
        ])
      );
    });

    it('fetches trucks when the Camion category is selected', async () => {
      mockGet.mockImplementation(withOptions({'/trucks': [makeTruck({plateNumber: 'GN-3310-C'})]}));
      const {getByLabelText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.change(getByLabelText('Catégorie'), {target: {value: 'Truck'}});
      await waitFor(() => expect(mockGet).toHaveBeenCalledWith('/trucks?per_page=100&page=1'));
    });

    it('shows the fetched trucks in the entity picker once Camion is selected', async () => {
      mockGet.mockImplementation(withOptions({'/trucks': [makeTruck({plateNumber: 'GN-3310-C'})]}));
      const {getByLabelText, getByText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.change(getByLabelText('Catégorie'), {target: {value: 'Truck'}});
      await fireEvent.focus(getByLabelText('Lié à'));
      await waitFor(() => expect(getByText('GN-3310-C')).toBeInTheDocument());
    });

    it('fetches tanks when the Citerne category is selected', async () => {
      mockGet.mockImplementation(withOptions({'/tanks': [makeTank({plateNumber: 'CIT-042'})]}));
      const {getByLabelText, getByText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await fireEvent.change(getByLabelText('Catégorie'), {target: {value: 'Tank'}});
      await fireEvent.focus(getByLabelText('Lié à'));
      await waitFor(() => expect(getByText('CIT-042')).toBeInTheDocument());
    });

    it('clears the selected entity when the category changes', async () => {
      mockGet.mockImplementation(
        withOptions({
          '/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})],
          '/tanks': [makeTank({id: 2, plateNumber: 'CIT-042'})],
        })
      );
      const {getByLabelText, getByText, queryByText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      await selectTruckEntity(getByLabelText, getByText);
      expect(getByLabelText('Lié à')).toHaveValue('GN-3310-C');

      await fireEvent.change(getByLabelText('Catégorie'), {target: {value: 'Tank'}});
      await waitFor(() => expect(queryByText('GN-3310-C')).not.toBeInTheDocument());
      expect(getByLabelText('Lié à')).toHaveValue('');
    });

    it('shows the selected file name once a file is chosen', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const {getByLabelText, getByText, queryByText} = render(NewDocumentDrawer, {
        open: true,
        onClose: vi.fn(),
        onCreated: vi.fn(),
      });
      expect(getByText('Aucun fichier sélectionné')).toBeInTheDocument();
      await fireEvent.input(getByLabelText('Fichier'), {target: {files: [pdfFile()]}});
      await waitFor(() => expect(getByText('insurance.pdf')).toBeInTheDocument());
      expect(queryByText('Aucun fichier sélectionné')).not.toBeInTheDocument();
    });

    it('calls onClose when clicking the overlay', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByRole} = render(NewDocumentDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByRole('presentation', {hidden: true}));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking the close button', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByLabelText} = render(NewDocumentDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByLabelText('Fermer'));
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when pressing Escape', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      render(NewDocumentDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).toHaveBeenCalled();
    });

    it('calls onClose when clicking Annuler', async () => {
      mockGet.mockReturnValue(new Promise(() => {}));
      const onClose = vi.fn();
      const {getByText} = render(NewDocumentDrawer, {open: true, onClose, onCreated: vi.fn()});
      await fireEvent.click(getByText('Annuler'));
      expect(onClose).toHaveBeenCalled();
    });

    describe('validation', () => {
      it('shows required errors when submitting an empty form', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Ajouter le document'));
        await waitFor(() => expect(getByText('Le fichier est requis')).toBeInTheDocument());
        expect(getByText('Le nom du document est requis')).toBeInTheDocument();
        expect(getByText('La catégorie est requise')).toBeInTheDocument();
        expect(getByText("L'entité liée est requise")).toBeInTheDocument();
        expect(getByText("La date d'émission est requise")).toBeInTheDocument();
      });

      it('rejects an expiry date before the issue date', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({plateNumber: 'GN-3310-C'})]})
        );
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.input(getByLabelText("Date d'émission"), {target: {value: '2026-06-01'}});
        await fireEvent.input(getByLabelText("Date d'expiration (optionnel)"), {
          target: {value: '2026-01-01'},
        });
        await waitFor(() =>
          expect(
            getByText("La date d'expiration doit être postérieure à la date d'émission")
          ).toBeInTheDocument()
        );
      });

      it('does not call createDocument when required fields are missing', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.click(getByText('Ajouter le document'));
        await waitFor(() => expect(getByText('Le fichier est requis')).toBeInTheDocument());
        expect(mockPostForm).not.toHaveBeenCalled();
      });

      it('rejects a file type that is not a PDF or image', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({plateNumber: 'GN-3310-C'})]})
        );
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        const textFile = new File(['content'], 'notes.txt', {type: 'text/plain'});
        await fireEvent.input(getByLabelText('Fichier'), {target: {files: [textFile]}});
        await waitFor(() =>
          expect(
            getByText(
              'Le fichier doit être un PDF, une image (JPEG, PNG, WebP), un document Word ou un fichier Excel'
            )
          ).toBeInTheDocument()
        );
      });

      it('rejects a file larger than the 10 Mo limit', async () => {
        mockGet.mockReturnValue(new Promise(() => {}));
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        const oversized = pdfFile();
        Object.defineProperty(oversized, 'size', {value: 11 * 1024 * 1024});
        await fireEvent.input(getByLabelText('Fichier'), {target: {files: [oversized]}});
        await waitFor(() =>
          expect(getByText('Le fichier ne doit pas dépasser 10 Mo')).toBeInTheDocument()
        );
      });
    });

    describe('submission', () => {
      it('submits the file and required fields as multipart form data', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})]})
        );
        mockPostForm.mockResolvedValue(makeDocument());
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Ajouter le document'));

        await waitFor(() => expect(mockPostForm).toHaveBeenCalled());
        const [path, form] = mockPostForm.mock.calls[0] as [string, FormData];
        expect(path).toBe('/documents/create');
        const entries = formEntries(form);
        expect(entries.title).toBe('Assurance 2026');
        expect(entries.number).toBe('INS-2026');
        expect(entries.documentable_type).toBe('Truck');
        expect(entries.documentable_id).toBe('1');
        expect(entries.file).toBeInstanceOf(File);
        expect((entries.file as File).name).toBe('insurance.pdf');
        expect(entries.doc_type).toBeUndefined();
        expect(entries.issued_on).toBe('2026-01-01');
        expect(entries.expires_on).toBeUndefined();
      });

      it('submits successfully without a number, letting the backend auto-generate one', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})]})
        );
        mockPostForm.mockResolvedValue(makeDocument({number: 'DT-42'}));
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fireEvent.input(getByLabelText('Nom du document'), {
          target: {value: 'Assurance 2026'},
        });
        await fireEvent.input(getByLabelText("Date d'émission"), {
          target: {value: '2026-01-01'},
        });
        await selectTruckEntity(getByLabelText, getByText);
        await fireEvent.input(getByLabelText('Fichier'), {target: {files: [pdfFile()]}});
        await waitFor(() => expect(getByText('Ajouter le document')).not.toBeDisabled());
        await fireEvent.click(getByText('Ajouter le document'));

        await waitFor(() => expect(mockPostForm).toHaveBeenCalled());
        const [, form] = mockPostForm.mock.calls[0] as [string, FormData];
        expect(formEntries(form).number).toBeUndefined();
      });

      it('includes the expiry date when filled in', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})]})
        );
        mockPostForm.mockResolvedValue(makeDocument());
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.input(getByLabelText("Date d'expiration (optionnel)"), {
          target: {value: '2027-01-01'},
        });
        await fireEvent.click(getByText('Ajouter le document'));

        await waitFor(() => expect(mockPostForm).toHaveBeenCalled());
        const [, form] = mockPostForm.mock.calls[0] as [string, FormData];
        expect(formEntries(form).expires_on).toBe('2027-01-01');
      });

      it('includes the document type when selected', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})]})
        );
        mockPostForm.mockResolvedValue(makeDocument());
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose: vi.fn(),
          onCreated: vi.fn(),
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.change(getByLabelText('Type de document (optionnel)'), {
          target: {value: 'truck_insurance'},
        });
        await fireEvent.click(getByText('Ajouter le document'));

        await waitFor(() => expect(mockPostForm).toHaveBeenCalled());
        const [, form] = mockPostForm.mock.calls[0] as [string, FormData];
        expect(formEntries(form).doc_type).toBe('truck_insurance');
      });

      it('calls onCreated and onClose on success', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})]})
        );
        mockPostForm.mockResolvedValue(makeDocument());
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Ajouter le document'));

        await waitFor(() => expect(onCreated).toHaveBeenCalled());
        expect(onClose).toHaveBeenCalled();
      });

      it('shows the API error and does not close on failure', async () => {
        mockGet.mockImplementation(
          withOptions({'/trucks': [makeTruck({id: 1, plateNumber: 'GN-3310-C'})]})
        );
        mockPostForm.mockRejectedValue(new Error('Ce numéro est déjà utilisé'));
        const onClose = vi.fn();
        const onCreated = vi.fn();
        const {getByLabelText, getByText} = render(NewDocumentDrawer, {
          open: true,
          onClose,
          onCreated,
        });
        await fillRequiredFields(getByLabelText, getByText);
        await fireEvent.click(getByText('Ajouter le document'));

        await waitFor(() => expect(getByText('Ce numéro est déjà utilisé')).toBeInTheDocument());
        expect(onCreated).not.toHaveBeenCalled();
        expect(onClose).not.toHaveBeenCalled();
      });
    });
  });
});
