import {api} from './client';
import type {Session} from '$lib/types/session';

export const login = (email: string, password: string): Promise<Session> =>
  api.post<Session>('/sessions', {email, password});

export const validateSession = (): Promise<void> => api.get<void>('/me');

export const logout = (): Promise<void> => api.delete<void>('/sessions');
