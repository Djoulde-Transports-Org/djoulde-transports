<script lang="ts">
  import type {Snippet} from 'svelte';

  let {
    type = 'button',
    disabled = false,
    variant = 'primary',
    onclick,
    children,
    ...attrs
  }: {
    type?: 'submit' | 'button' | 'reset';
    disabled?: boolean;
    variant?: 'primary' | 'ghost';
    onclick?: () => void;
    children: Snippet;
    [key: string]: unknown;
  } = $props();
</script>

{#if variant === 'primary'}
  <button
    {type}
    {disabled}
    {onclick}
    {...attrs}
    class="w-full py-2.5 px-4 rounded-lg text-white font-medium
           focus:outline-none focus:ring-2 focus:ring-offset-2
           disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
    style="background-color: #2B5BAD;"
    onmouseenter={(e) => !disabled && (e.currentTarget.style.backgroundColor = '#1A3A6B')}
    onmouseleave={(e) => (e.currentTarget.style.backgroundColor = '#2B5BAD')}
  >
    {@render children()}
  </button>
{:else if variant === 'ghost'}
  <button
    {type}
    {disabled}
    {onclick}
    {...attrs}
    class="font-medium text-center text-sm hover:underline disabled:opacity-50 disabled:cursor-not-allowed"
    style="color: #2B5BAD;"
  >
    {@render children()}
  </button>
{/if}
