import {get} from 'svelte/store';
import {browser} from '$app/environment';
import {goto} from '$app/navigation';
import {resolve} from '$app/paths';
import {authStore} from '$lib/store/session/auth';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1';

export class ApiRequestError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly details?: unknown
  ) {
    super(message);
    this.name = 'ApiRequestError';
  }
}

const request = async <T>(path: string, options: RequestInit = {}): Promise<T> => {
  const token = get(authStore)?.access_token;

  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token ? {Authorization: `Bearer ${token}`} : {}),
    ...(options.headers ?? {}),
  };

  const response = await fetch(`${BASE_URL}${path}`, {...options, headers});

  if (response.status === 401) {
    authStore.clearSession();
    if (browser) await goto(resolve('/login'));
    throw new ApiRequestError('unauthorized', 'Session expirée. Veuillez vous reconnecter.');
  }

  const data = await response.json();

  if (!response.ok) {
    throw new ApiRequestError(
      data.error?.code ?? String(response.status),
      data.error?.message ?? 'An unexpected error occurred',
      data.error?.details
    );
  }

  return data as T;
};

export const api = {
  post: <T>(path: string, body: unknown) =>
    request<T>(path, {method: 'POST', body: JSON.stringify(body)}),
  get: <T>(path: string) => request<T>(path, {method: 'GET'}),
  put: <T>(path: string, body: unknown) =>
    request<T>(path, {method: 'PUT', body: JSON.stringify(body)}),
  patch: <T>(path: string, body: unknown) =>
    request<T>(path, {method: 'PATCH', body: JSON.stringify(body)}),
  delete: <T>(path: string) => request<T>(path, {method: 'DELETE'}),
};
