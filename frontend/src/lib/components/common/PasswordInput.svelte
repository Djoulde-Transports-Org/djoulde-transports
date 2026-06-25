<script lang="ts">
  let {
    id,
    name,
    label,
    placeholder = '',
    autocomplete,
    error,
  }: {
    id: string;
    name: string;
    label: string;
    placeholder?: string;
    autocomplete?: HTMLInputElement['autocomplete'];
    error?: string | string[] | null;
  } = $props();

  const errorMessage = $derived(Array.isArray(error) ? error[0] : error);
  let revealed = $state(false);
</script>

<div>
  <label
    for={id}
    class="block text-sm font-medium mb-1 {errorMessage ? 'text-red-600' : 'text-gray-700'}"
  >
    {label}
  </label>
  <div class="relative">
    <input
      {id}
      {name}
      type={revealed ? 'text' : 'password'}
      {placeholder}
      {autocomplete}
      class="w-full px-4 py-2.5 pr-11 rounded-lg border focus:outline-none focus:ring-2 focus:border-transparent transition-colors
             {errorMessage
        ? 'border-red-500 text-red-600 placeholder-red-400 focus:ring-red-400'
        : 'border-gray-300 text-gray-900 placeholder-gray-400 focus:ring-[#2B5BAD]'}"
    />
    <button
      type="button"
      onclick={() => (revealed = !revealed)}
      aria-label={revealed ? 'Hide password' : 'Show password'}
      class="absolute inset-y-0 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 transition-colors"
    >
      {#if revealed}
        <!-- eye-off -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="w-5 h-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"
          />
        </svg>
      {:else}
        <!-- eye -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="w-5 h-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
          />
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
          />
        </svg>
      {/if}
    </button>
  </div>
  {#if errorMessage}
    <p class="mt-1 text-xs text-red-500">{errorMessage}</p>
  {/if}
</div>
