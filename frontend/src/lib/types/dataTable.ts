import type {Snippet} from 'svelte';

export type Row = Record<string, unknown>;

export type Column = {
  key: string;
  label: string;
  render?: Snippet<[unknown, Row]>;
};

export type FilterChip = {
  key: string;
  label: string;
  value: string;
};

export type PaginatedResponse = {
  data: Row[];
  nextCursor: string | null;
  hasMore: boolean;
};
