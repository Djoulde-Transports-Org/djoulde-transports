import {get} from 'svelte/store';
import {browser} from '$app/environment';
import {goto} from '$app/navigation';
import {resolve} from '$app/paths';
import {page} from '$app/stores';
import {authStore} from '$lib/store/session/auth';
import {toCamelCase, toSnakeCase} from '$lib/utility/case';

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
  const token = get(authStore)?.accessToken;
  const isFormData = options.body instanceof FormData;

  const headers: HeadersInit = {
    // The browser must set its own multipart boundary for FormData bodies.
    ...(isFormData ? {} : {'Content-Type': 'application/json'}),
    ...(token ? {Authorization: `Bearer ${token}`} : {}),
    ...(options.headers ?? {}),
  };

  const response = await fetch(`${BASE_URL}${path}`, {...options, headers});

  if (response.status === 401) {
    authStore.clearSession();
    if (browser) {
      const currentPath = get(page).url.pathname;
      // Query param must be appended to the resolved path — resolve() cannot be the direct argument here
      // eslint-disable-next-line svelte/no-navigation-without-resolve
      await goto(`${resolve('/login')}?redirect=${encodeURIComponent(currentPath)}`);
    }
    throw new ApiRequestError('unauthorized', 'Session expirée. Veuillez vous reconnecter.');
  }

  const data = toCamelCase<{error?: {code?: string; message?: string; details?: unknown}}>(
    await response.json()
  );

  if (!response.ok) {
    throw new ApiRequestError(
      data.error?.code ?? String(response.status),
      data.error?.message ?? 'An unexpected error occurred',
      data.error?.details
    );
  }

  return data as T;
};

const withBody = (method: string, body: unknown): RequestInit => ({
  method,
  body: JSON.stringify(toSnakeCase(body)),
});

const withForm = (method: string, form: FormData): RequestInit => ({method, body: form});

export const api = {
  post: <T>(path: string, body: unknown) => request<T>(path, withBody('POST', body)),
  postForm: <T>(path: string, form: FormData) => request<T>(path, withForm('POST', form)),
  get: <T>(path: string) => request<T>(path, {method: 'GET'}),
  put: <T>(path: string, body: unknown) => request<T>(path, withBody('PUT', body)),
  patch: <T>(path: string, body: unknown) => request<T>(path, withBody('PATCH', body)),
  delete: <T>(path: string) => request<T>(path, {method: 'DELETE'}),
};
