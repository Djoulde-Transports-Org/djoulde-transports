<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import type {IconName} from '$lib/components/common/Icon.svelte';

  let {
    label,
    value = '',
    sub = '',
    icon,
    loading = false,
  }: {
    label: string;
    value?: string;
    sub?: string;
    icon: IconName;
    loading?: boolean;
  } = $props();
</script>

<div class="bg-surface border border-border rounded-xl p-5 flex flex-col gap-4">
  <div class="flex items-center justify-between gap-2">
    <span class="text-[11px] font-semibold text-dt-text-muted uppercase tracking-wider leading-none"
      >{label}</span
    >
    <span class="text-accent/60">
      <Icon name={icon} size={16} strokeWidth={1.5} />
    </span>
  </div>

  {#if loading}
    <div class="flex flex-col gap-2">
      <div class="h-8 w-2/3 bg-surface-2 rounded animate-pulse"></div>
      <div class="h-3 w-4/5 bg-surface-2 rounded animate-pulse"></div>
    </div>
  {:else}
    <div class="flex flex-col gap-1">
      <span class="text-[28px] font-bold text-dt-text leading-none tabular-nums">{value}</span>
      <span class="text-[12px] text-dt-text-muted leading-relaxed">{sub}</span>
    </div>
  {/if}
</div>
