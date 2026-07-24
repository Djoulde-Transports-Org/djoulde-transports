import {api} from '$lib/api/client';
import {login} from '$lib/api/sessions';
import type {Session} from '$lib/types/session';

vi.mock('$lib/api/client', () => ({
  api: {post: vi.fn()},
}));

const mockSession = (overrides?: Partial<Session>): Session => ({
  accessToken: 'tok_abc',
  tokenType: 'Bearer',
  expiresIn: 7200,
  createdAt: 1700000000,
  userId: 1,
  roles: [],
  ...overrides,
});

describe('login', () => {
  beforeEach(() => {
    vi.mocked(api.post).mockResolvedValue(mockSession());
  });

  it('calls api.post with /sessions and the supplied credentials', async () => {
    await login('user@example.com', 'secret');
    expect(api.post).toHaveBeenCalledWith('/sessions', {
      email: 'user@example.com',
      password: 'secret',
    });
  });

  it('returns the session from the API', async () => {
    const session = mockSession();
    vi.mocked(api.post).mockResolvedValue(session);
    expect(await login('user@example.com', 'secret')).toEqual(session);
  });

  it('returns an empty roles array when the user has no roles', async () => {
    vi.mocked(api.post).mockResolvedValue(mockSession({roles: []}));
    const result = await login('user@example.com', 'secret');
    expect(result.roles).toEqual([]);
  });

  it('returns the user roles when present', async () => {
    vi.mocked(api.post).mockResolvedValue(mockSession({roles: ['super_admin']}));
    const result = await login('user@example.com', 'secret');
    expect(result.roles).toEqual(['super_admin']);
  });
});
