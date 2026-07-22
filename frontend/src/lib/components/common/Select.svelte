<script lang="ts">
  type OptionValue = string | number;

  let {
    id,
    name,
    label,
    options,
    value = '',
    placeholder = 'Sélectionner...',
    error,
  }: {
    id: string;
    name: string;
    label: string;
    options: {value: OptionValue; label: string}[];
    value?: OptionValue;
    placeholder?: string;
    error?: string | string[] | null;
  } = $props();

  const errorMessage = $derived(Array.isArray(error) ? error[0] : error);
</script>

<div>
  <label
    for={id}
    class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {errorMessage
      ? 'text-dt-red'
      : ''}"
  >
    {label}
  </label>
  <select
    {id}
    {name}
    class="w-full px-3 py-2 text-[13px] rounded-lg border bg-surface text-dt-text focus:outline-none focus:ring-1 transition-colors
      {errorMessage ? 'border-dt-red focus:ring-dt-red/40' : 'border-border focus:ring-accent/40'}"
  >
    <option value="" selected={value === ''}>{placeholder}</option>
    {#each options as option (option.value)}
      <option value={option.value} selected={value === option.value}>{option.label}</option>
    {/each}
  </select>
  {#if errorMessage}
    <p class="mt-1 text-[11px] text-dt-red">{errorMessage}</p>
  {/if}
</div>
