<script lang="ts">
  let {
    id,
    name,
    label,
    type = 'text',
    placeholder = '',
    autocomplete,
    error,
  }: {
    id: string;
    name: string;
    label: string;
    type?: string;
    placeholder?: string;
    autocomplete?: HTMLInputElement['autocomplete'];
    error?: string | string[] | null;
  } = $props();

  const errorMessage = $derived(Array.isArray(error) ? error[0] : error);
</script>

<div>
  <label
    for={id}
    class="block text-sm font-medium mb-1 {errorMessage ? 'text-red-600' : 'text-gray-700'}"
  >
    {label}
  </label>
  <input
    {id}
    {name}
    {type}
    {placeholder}
    {autocomplete}
    class="w-full px-4 py-2.5 rounded-lg border focus:outline-none focus:ring-2 focus:border-transparent transition-colors
           {errorMessage
      ? 'border-red-500 text-red-600 placeholder-red-400 focus:ring-red-400'
      : 'border-gray-300 text-gray-900 placeholder-gray-400 focus:ring-[#2B5BAD]'}"
  />
  {#if errorMessage}
    <p class="mt-1 text-xs text-red-500">{errorMessage}</p>
  {/if}
</div>
