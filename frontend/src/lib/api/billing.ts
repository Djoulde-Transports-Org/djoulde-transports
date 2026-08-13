import {api} from './client';
import type {BillingStatement} from '$lib/types/billing';

type BillingStatementResult = {data: BillingStatement | null; error: string | null};

export const generateBillingStatement = async (month: string): Promise<BillingStatementResult> => {
  try {
    return {
      data: await api.post<BillingStatement>('/billing_statements/generate', {month}),
      error: null,
    };
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};

export const getBillingStatement = async (id: number | string): Promise<BillingStatementResult> => {
  try {
    return {data: await api.get<BillingStatement>(`/billing_statements/${id}`), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
