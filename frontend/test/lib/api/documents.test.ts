import {createDocument} from '$lib/api/documents';
import {makeDocument} from '../../mocks/document';

const mockPostForm = vi.hoisted(() => vi.fn());
vi.mock('$lib/api/client', () => ({api: {postForm: mockPostForm}}));

describe('createDocument', () => {
  afterEach(() => vi.clearAllMocks());

  it('posts to /documents/create with a FormData body', async () => {
    mockPostForm.mockResolvedValue(makeDocument());
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      file,
    });

    expect(mockPostForm).toHaveBeenCalledWith('/documents/create', expect.any(FormData));
  });

  it('snake_cases the field names and stringifies non-file values', async () => {
    mockPostForm.mockResolvedValue(makeDocument());
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      docType: 'truck_insurance',
      file,
    });

    const form = mockPostForm.mock.calls[0][1] as FormData;
    expect(form.get('documentable_type')).toBe('Truck');
    expect(form.get('documentable_id')).toBe('1');
    expect(form.get('number')).toBe('INS-2026');
    expect(form.get('title')).toBe('Assurance 2026');
    expect(form.get('doc_type')).toBe('truck_insurance');
    expect(form.get('file')).toBe(file);
  });

  it('omits number when not provided, letting the backend auto-generate one', async () => {
    mockPostForm.mockResolvedValue(makeDocument({number: 'DT-42'}));
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      file,
    });

    const form = mockPostForm.mock.calls[0][1] as FormData;
    expect(form.has('number')).toBe(false);
  });

  it('omits doc_type when not provided', async () => {
    mockPostForm.mockResolvedValue(makeDocument());
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      file,
    });

    const form = mockPostForm.mock.calls[0][1] as FormData;
    expect(form.has('doc_type')).toBe(false);
  });

  it('includes expires_on when provided and omits it otherwise', async () => {
    mockPostForm.mockResolvedValue(makeDocument());
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      expiresOn: '2027-01-01',
      file,
    });

    const form = mockPostForm.mock.calls[0][1] as FormData;
    expect(form.get('issued_on')).toBe('2026-01-01');
    expect(form.get('expires_on')).toBe('2027-01-01');

    mockPostForm.mockClear();
    await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      file,
    });

    const secondForm = mockPostForm.mock.calls[0][1] as FormData;
    expect(secondForm.has('expires_on')).toBe(false);
  });

  it('returns the created document on success', async () => {
    const document = makeDocument({id: 42});
    mockPostForm.mockResolvedValue(document);
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    const {data, error} = await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      file,
    });

    expect(data).toEqual(document);
    expect(error).toBeNull();
  });

  it('returns an error message on failure', async () => {
    mockPostForm.mockRejectedValue(new Error('Ce numéro est déjà utilisé'));
    const file = new File(['content'], 'insurance.pdf', {type: 'application/pdf'});

    const {data, error} = await createDocument({
      documentableType: 'Truck',
      documentableId: 1,
      number: 'INS-2026',
      title: 'Assurance 2026',
      issuedOn: '2026-01-01',
      file,
    });

    expect(data).toBeNull();
    expect(error).toBe('Ce numéro est déjà utilisé');
  });
});
