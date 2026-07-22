<script lang="ts">
  import type {Snippet} from 'svelte';
  import {onMount} from 'svelte';
  import {api} from '$lib/api/client';
  import Icon from '$lib/components/common/Icon.svelte';

  type Row = Record<string, unknown>;

  type Column = {
    key: string;
    label: string;
    render?: Snippet<[unknown, Row]>;
  };

  type FilterChip = {
    key: string;
    label: string;
    value: string;
  };

  type PaginatedResponse = {
    data: Row[];
    next_cursor: string | null;
    has_more: boolean;
  };

  let {
    endpoint,
    columns,
    filters = [],
    searchParam,
    paginated = false,
    limit = 50,
    rowClickable = false,
    actions,
    empty,
    error: errorSnippet,
  }: {
    endpoint: string;
    columns: Column[];
    filters?: FilterChip[];
    searchParam?: string;
    paginated?: boolean;
    limit?: number;
    rowClickable?: boolean;
    actions?: Snippet;
    empty?: Snippet;
    error?: Snippet<[string]>;
  } = $props();

  let rows = $state<Row[]>([]);
  let loading = $state(true);
  let errorMsg = $state<string | null>(null);
  let search = $state('');
  let activeFilters = $state<Record<string, string>>({});

  let cursorStack = $state<(string | null)[]>([null]);
  let page = $state(0);
  let hasMore = $state(false);

  const buildUrl = (cursor: string | null) => {
    const parts: string[] = [];
    for (const [k, v] of Object.entries(activeFilters)) {
      parts.push(`${encodeURIComponent(k)}=${encodeURIComponent(v)}`);
    }
    if (searchParam && search.trim()) {
      parts.push(`${encodeURIComponent(searchParam)}=${encodeURIComponent(search.trim())}`);
    }
    if (paginated) {
      parts.push(`limit=${limit}`);
      if (cursor) parts.push(`after=${encodeURIComponent(cursor)}`);
    }
    return parts.length ? `${endpoint}?${parts.join('&')}` : endpoint;
  };

  const load = async (cursor: string | null) => {
    loading = true;
    errorMsg = null;
    try {
      const url = buildUrl(cursor);
      if (paginated) {
        const res = await api.get<PaginatedResponse>(url);
        rows = res.data;
        hasMore = res.has_more;
        if (res.next_cursor) {
          cursorStack = [...cursorStack.slice(0, page + 1), res.next_cursor];
        }
      } else {
        rows = await api.get<Row[]>(url);
      }
    } catch (e) {
      errorMsg = e instanceof Error ? e.message : 'Une erreur est survenue.';
    } finally {
      loading = false;
    }
  };

  const resetAndLoad = () => {
    cursorStack = [null];
    page = 0;
    hasMore = false;
    load(null);
  };

  const toggleFilter = (chip: FilterChip) => {
    const next = {...activeFilters};
    if (next[chip.key] === chip.value) delete next[chip.key];
    else next[chip.key] = chip.value;
    activeFilters = next;
    resetAndLoad();
  };

  let searchTimer: ReturnType<typeof setTimeout>;

  const onSearchInput = (e: Event) => {
    search = (e.target as HTMLInputElement).value;
    clearTimeout(searchTimer);
    searchTimer = setTimeout(resetAndLoad, 300);
  };

  const goNext = () => {
    if (!hasMore) return;
    page++;
    load(cursorStack[page] ?? null);
  };

  const goPrev = () => {
    if (page <= 0) return;
    page--;
    hasMore = true;
    load(cursorStack[page] ?? null);
  };

  onMount(() => {
    load(null);
    return () => clearTimeout(searchTimer);
  });

  export const refresh = () => resetAndLoad();
</script>

<div class="flex flex-col gap-3">
  {#if searchParam || filters.length > 0 || actions}
    <div class="flex items-center gap-2 flex-wrap">
      {#if searchParam}
        <div class="relative">
          <span
            class="absolute left-2.5 top-1/2 -translate-y-1/2 text-dt-text-muted pointer-events-none"
          >
            <Icon name="search" size={13} />
          </span>
          <input
            type="text"
            placeholder="Rechercher..."
            oninput={onSearchInput}
            class="pl-8 pr-3 py-1.5 text-[13px] bg-surface border border-border rounded-lg text-dt-text placeholder:text-dt-text-muted focus:outline-none focus:ring-1 focus:ring-accent/40 w-52 transition-colors"
          />
        </div>
      {/if}

      {#each filters as chip (chip.key + chip.value)}
        {@const active = activeFilters[chip.key] === chip.value}
        <button
          onclick={() => toggleFilter(chip)}
          class="px-3 py-1 text-[12px] font-medium rounded-full border transition-colors duration-[130ms]
            {active
            ? 'bg-accent/10 text-accent border-accent/50'
            : 'bg-surface border-border text-dt-text-muted hover:text-dt-text hover:border-dt-text-muted'}"
        >
          {chip.label}
        </button>
      {/each}

      {#if actions}
        <div class="ml-auto">
          {@render actions()}
        </div>
      {/if}
    </div>
  {/if}

  <div class="overflow-x-auto rounded-lg border border-border">
    <table class="w-full text-sm min-w-full">
      <thead>
        <tr class="bg-surface border-b border-border">
          {#each columns as col (col.key)}
            <th
              class="px-4 py-3 text-left text-[11px] font-semibold text-dt-text-muted uppercase tracking-wider whitespace-nowrap"
            >
              {col.label}
            </th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#if loading}
          {#each [0, 1, 2, 3, 4] as i (i)}
            <tr class="border-b border-border-soft last:border-0">
              {#each columns as col, j (col.key)}
                <td class="px-4 py-3">
                  <div
                    class="h-3.5 bg-surface-2 rounded animate-pulse {j % 2 === 0
                      ? 'w-3/4'
                      : 'w-1/2'}"
                  ></div>
                </td>
              {/each}
            </tr>
          {/each}
        {:else if errorMsg}
          <tr>
            <td colspan={columns.length} class="px-4 py-12 text-center">
              {#if errorSnippet}
                {@render errorSnippet(errorMsg)}
              {:else}
                <p class="text-dt-text-muted text-sm">{errorMsg}</p>
              {/if}
            </td>
          </tr>
        {:else if rows.length === 0}
          <tr>
            <td colspan={columns.length} class="px-4 py-12 text-center">
              {#if empty}
                {@render empty()}
              {:else}
                <p class="text-dt-text-muted text-sm">Aucun résultat.</p>
              {/if}
            </td>
          </tr>
        {:else}
          {#each rows as row, i (i)}
            <tr
              class="border-b border-border-soft last:border-0 hover:bg-surface-2/40 transition-colors duration-[130ms] {rowClickable
                ? 'cursor-pointer'
                : ''}"
            >
              {#each columns as col (col.key)}
                <td class="px-4 py-3 text-dt-text">
                  {#if col.render}
                    {@render col.render(row[col.key], row)}
                  {:else}
                    {row[col.key] ?? ''}
                  {/if}
                </td>
              {/each}
            </tr>
          {/each}
        {/if}
      </tbody>
    </table>
  </div>

  {#if paginated}
    <div class="flex items-center justify-between px-1">
      <button
        onclick={goPrev}
        disabled={page === 0}
        class="flex items-center gap-1.5 px-3 py-1.5 text-[13px] font-medium rounded-lg border border-border text-dt-text-mid hover:text-dt-text hover:bg-surface transition-colors duration-[130ms] disabled:opacity-40 disabled:cursor-not-allowed"
      >
        <Icon name="chevron-left" size={14} />
        Précédent
      </button>

      <span class="text-[12px] text-dt-text-muted">Page {page + 1}</span>

      <button
        onclick={goNext}
        disabled={!hasMore}
        class="flex items-center gap-1.5 px-3 py-1.5 text-[13px] font-medium rounded-lg border border-border text-dt-text-mid hover:text-dt-text hover:bg-surface transition-colors duration-[130ms] disabled:opacity-40 disabled:cursor-not-allowed"
      >
        Suivant
        <Icon name="chevron-right" size={14} />
      </button>
    </div>
  {/if}
</div>
