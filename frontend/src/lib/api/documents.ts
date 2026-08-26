import {api} from './client';
import {camelToSnake} from '$lib/utility/case';
import type {DocumentableType, DocType, FleetDocument} from '$lib/types/document';

type DocumentResult = {data: FleetDocument | null; error: string | null};

export type CreateDocumentPayload = {
  documentableType: DocumentableType;
  documentableId: number;
  number?: string;
  title: string;
  docType?: DocType;
  issuedOn: string;
  expiresOn?: string;
  file: File;
};

export const createDocument = async (payload: CreateDocumentPayload): Promise<DocumentResult> => {
  try {
    const form = new FormData();
    for (const [key, value] of Object.entries(payload)) {
      if (value === undefined || value === '') continue;
      form.append(camelToSnake(key), value instanceof File ? value : String(value));
    }
    return {data: await api.postForm<FleetDocument>('/documents/create', form), error: null};
  } catch (e) {
    return {data: null, error: e instanceof Error ? e.message : 'Une erreur est survenue.'};
  }
};
