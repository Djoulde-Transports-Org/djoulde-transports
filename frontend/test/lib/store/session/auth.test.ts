import {get} from 'svelte/store';
import {authStore, isAuthenticated} from '$lib/store/session/auth';
import type {Session} from '$lib/types/session';

vi.mock('$app/environment', () => ({browser: true}));

const STORAGE_KEY = 'djoulde_session';

const makeSession = (overrides?: Partial<Session>): Session => ({
  accessToken: 'tok_abc',
  tokenType: 'Bearer',
  expiresIn: 7200,
  createdAt: 1700000000,
  userId: 1,
  roles: [],
  ...overrides,
});

describe('authStore', () => {
  beforeEach(() => {
    localStorage.clear();
    authStore.clearSession();
  });

  describe('initial state', () => {
    it('is null when localStorage is empty', () => {
      expect(get(authStore)).toBeNull();
    });

    it('isAuthenticated is false when the store is null', () => {
      expect(get(isAuthenticated)).toBe(false);
    });
  });

  describe('setSession', () => {
    it('updates the store value', () => {
      const session = makeSession();
      authStore.setSession(session);
      expect(get(authStore)).toEqual(session);
    });

    it('persists the session to localStorage', () => {
      const session = makeSession();
      authStore.setSession(session);
      expect(JSON.parse(localStorage.getItem(STORAGE_KEY)!)).toEqual(session);
    });

    it('stores an empty roles array', () => {
      authStore.setSession(makeSession({roles: []}));
      expect(get(authStore)?.roles).toEqual([]);
    });

    it('stores a non-empty roles array', () => {
      authStore.setSession(makeSession({roles: ['super_admin']}));
      expect(get(authStore)?.roles).toEqual(['super_admin']);
    });

    it('persists roles to localStorage', () => {
      authStore.setSession(makeSession({roles: ['super_admin']}));
      const stored: Session = JSON.parse(localStorage.getItem(STORAGE_KEY)!);
      expect(stored.roles).toEqual(['super_admin']);
    });

    it('makes isAuthenticated true', () => {
      authStore.setSession(makeSession());
      expect(get(isAuthenticated)).toBe(true);
    });
  });

  describe('clearSession', () => {
    it('sets the store to null', () => {
      authStore.setSession(makeSession());
      authStore.clearSession();
      expect(get(authStore)).toBeNull();
    });

    it('removes the session from localStorage', () => {
      authStore.setSession(makeSession());
      authStore.clearSession();
      expect(localStorage.getItem(STORAGE_KEY)).toBeNull();
    });

    it('makes isAuthenticated false', () => {
      authStore.setSession(makeSession());
      authStore.clearSession();
      expect(get(isAuthenticated)).toBe(false);
    });
  });
});
