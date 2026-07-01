<script lang="ts">
  import type {Snippet} from 'svelte';

  let {title, actions}: {title: string; actions?: Snippet} = $props();

  let now = $state(new Date());

  $effect(() => {
    const id = setInterval(() => {
      now = new Date();
    }, 1000);
    return () => clearInterval(id);
  });

  const formatTime = (d: Date) =>
    d.toLocaleTimeString('fr-FR', {hour: '2-digit', minute: '2-digit', second: '2-digit'});
</script>

<header
  class="h-14 flex items-center justify-between px-6 border-b border-border bg-surface sticky top-0 z-30"
>
  <h1 class="text-[15px] font-semibold text-dt-text">{title}</h1>

  <div class="flex items-center gap-4">
    <div
      class="flex items-center gap-2 px-3 py-1.5 rounded-full bg-surface-2 border border-border text-[11px] font-medium text-dt-text-mid"
    >
      <span class="relative flex h-2 w-2">
        <span class="absolute inset-0 rounded-full bg-dt-green opacity-75 animate-ping"></span>
        <span class="relative rounded-full h-2 w-2 bg-dt-green"></span>
      </span>
      En direct
    </div>

    <span class="text-[12px] font-mono text-dt-text-muted tabular-nums">{formatTime(now)}</span>

    {#if actions}
      {@render actions()}
    {/if}
  </div>
</header>
