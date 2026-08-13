<script lang="ts">
  type OptionValue = string | number;
  type Option = {value: OptionValue; label: string};

  let {
    id,
    name,
    label,
    options,
    value = $bindable(''),
    emptyLabel = 'Aucune sélection',
    searchPlaceholder = 'Rechercher...',
    creatable = false,
    createLabel = (query: string) => `+ Créer « ${query} »`,
    error,
  }: {
    id: string;
    name: string;
    label: string;
    options: Option[];
    value?: OptionValue;
    emptyLabel?: string;
    searchPlaceholder?: string;
    creatable?: boolean;
    createLabel?: (query: string) => string;
    error?: string | string[] | null;
  } = $props();

  let query = $state('');
  let open = $state(false);

  const selected = $derived(
    options.find((option) => option.value === value) ??
      (creatable && value !== '' ? {value, label: String(value)} : null)
  );
  const errorMessage = $derived(Array.isArray(error) ? error[0] : error);

  const filtered = $derived(
    query.trim()
      ? options.filter((option) => option.label.toLowerCase().includes(query.trim().toLowerCase()))
      : options
  );

  const showCreateOption = $derived(
    creatable &&
      query.trim().length > 0 &&
      !options.some((option) => option.label.toLowerCase() === query.trim().toLowerCase())
  );

  const displayValue = $derived(open ? query : (selected?.label ?? ''));

  const openList = () => {
    query = '';
    open = true;
  };

  const closeList = () => {
    open = false;
    query = '';
  };

  const choose = (option: Option | null) => (event: MouseEvent) => {
    event.preventDefault();
    value = option?.value ?? '';
    closeList();
  };

  const onKeydown = (event: KeyboardEvent) => {
    if (event.key === 'Escape') closeList();
  };
</script>

<div class="relative">
  <label
    for={id}
    class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {errorMessage
      ? 'text-dt-red'
      : ''}"
  >
    {label}
  </label>
  <input type="hidden" {name} {value} />
  <input
    {id}
    type="text"
    role="combobox"
    aria-expanded={open}
    aria-controls="{id}-listbox"
    autocomplete="off"
    placeholder={open ? searchPlaceholder : emptyLabel}
    value={displayValue}
    oninput={(e) => (query = (e.target as HTMLInputElement).value)}
    onfocus={openList}
    onblur={closeList}
    onkeydown={onKeydown}
    class="w-full px-3 py-2 text-[13px] rounded-lg border bg-surface text-dt-text focus:outline-none focus:ring-1 transition-colors
      {errorMessage ? 'border-dt-red focus:ring-dt-red/40' : 'border-border focus:ring-accent/40'}"
  />
  {#if open}
    <ul
      id="{id}-listbox"
      role="listbox"
      class="absolute z-10 mt-1 w-full max-h-48 overflow-y-auto rounded-lg border border-border bg-surface shadow-lg"
    >
      <li>
        <button
          type="button"
          onmousedown={choose(null)}
          class="w-full text-left px-3 py-2 text-[13px] text-dt-text-muted hover:bg-surface-2 transition-colors"
        >
          {emptyLabel}
        </button>
      </li>
      {#each filtered as option (option.value)}
        <li>
          <button
            type="button"
            onmousedown={choose(option)}
            class="w-full text-left px-3 py-2 text-[13px] text-dt-text hover:bg-surface-2 transition-colors"
          >
            {option.label}
          </button>
        </li>
      {/each}
      {#if showCreateOption}
        {@const trimmedQuery = query.trim()}
        <li>
          <button
            type="button"
            onmousedown={choose({value: trimmedQuery, label: trimmedQuery})}
            class="w-full text-left px-3 py-2 text-[13px] text-accent hover:bg-surface-2 transition-colors"
          >
            {createLabel(trimmedQuery)}
          </button>
        </li>
      {/if}
      {#if filtered.length === 0 && !showCreateOption}
        <li class="px-3 py-2 text-[13px] text-dt-text-muted">Aucun résultat</li>
      {/if}
    </ul>
  {/if}
  {#if errorMessage}
    <p class="mt-1 text-[11px] text-dt-red">{errorMessage}</p>
  {/if}
</div>
