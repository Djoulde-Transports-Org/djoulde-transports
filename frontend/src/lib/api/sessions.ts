import {api} from './client';
import type {Session} from '$lib/types/session';

export function login(email: string, password: string): Promise<Session> {
  return api.post<Session>('/sessions', {email, password});
}
