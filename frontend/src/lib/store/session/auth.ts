import {writable, derived} from 'svelte/store';
import {browser} from '$app/environment';
import type {Session} from '$lib/types/session';

const STORAGE_KEY = 'djoulde_session';

const loadFromStorage = (): Session | null => {
  if (!browser) return null;
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as Session) : null;
  } catch {
    return null;
  }
};

const createAuthStore = () => {
  const {subscribe, set} = writable<Session | null>(loadFromStorage());

  return {
    subscribe,
    setSession(session: Session) {
      if (browser) localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
      set(session);
    },
    clearSession() {
      if (browser) localStorage.removeItem(STORAGE_KEY);
      set(null);
    },
  };
};

export const authStore = createAuthStore();
export const isAuthenticated = derived(authStore, ($auth) => $auth !== null);
