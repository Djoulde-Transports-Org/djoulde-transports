<script lang="ts">
  import {onMount} from 'svelte';
  import {resolve} from '$app/paths';
  import {getTrucks} from '$lib/api/trucks';
  import type {Truck} from '$lib/types/truck';

  let trucks = $state<Truck[]>([]);
  let loading = $state(true);
  let errorMsg = $state<string | null>(null);

  onMount(async () => {
    ({data: trucks, error: errorMsg} = await getTrucks());
    loading = false;
  });
</script>

<div class="bg-surface border border-border rounded-xl overflow-hidden">
  <div class="flex items-center justify-between px-5 py-4 border-b border-border">
    <span class="text-[13px] font-semibold text-dt-text">État de la flotte</span>
    <a href={resolve('/flotte')} class="text-[12px] text-accent hover:underline">Voir tout →</a>
  </div>

  <div class="divide-y divide-border-soft">
    {#if loading}
      {#each [0, 1, 2, 3, 4] as i (i)}
        <div class="flex items-center gap-4 px-5 py-3.5">
          <div class="h-3.5 w-28 bg-surface-2 rounded animate-pulse"></div>
          <div class="h-1.5 flex-1 bg-surface-2 rounded-full animate-pulse"></div>
          <div class="h-5 w-24 bg-surface-2 rounded-full animate-pulse"></div>
          <div class="h-3.5 w-32 bg-surface-2 rounded animate-pulse"></div>
        </div>
      {/each}
    {:else if errorMsg}
      <p class="px-5 py-10 text-center text-[13px] text-dt-red">{errorMsg}</p>
    {:else if trucks.length === 0}
      <p class="px-5 py-10 text-center text-[13px] text-dt-text-muted">Aucun camion.</p>
    {:else}
      {#each trucks as truck (truck.id)}
        <div class="flex items-center gap-4 px-5 py-3.5">
          <span class="w-28 shrink-0 font-mono text-[13px] font-bold text-dt-text truncate">
            {truck.plate_number}
          </span>

          <div class="relative flex-1 h-1.5 rounded-full bg-surface-2">
            {#if truck.status === 'on_trip'}
              <div
                class="truck-node absolute top-1/2 -translate-y-1/2 w-2.5 h-2.5 rounded-full bg-accent shadow-[0_0_6px_rgba(232,98,30,0.7)]"
              ></div>
            {:else if truck.status === 'in_maintenance'}
              <div
                class="absolute inset-0 rounded-full"
                style="background: repeating-linear-gradient(-45deg, rgba(192,154,32,0.3) 0px, rgba(192,154,32,0.3) 4px, transparent 4px, transparent 8px)"
              ></div>
            {:else}
              <div
                class="absolute left-2 top-1/2 -translate-y-1/2 w-2 h-2 rounded-full bg-dt-text-muted/30"
              ></div>
            {/if}
          </div>

          {#if truck.status === 'on_trip'}
            <span
              class="shrink-0 text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-accent/10 text-accent border border-accent/20"
              >EN ROUTE</span
            >
          {:else if truck.status === 'in_maintenance'}
            <span
              class="shrink-0 text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-dt-yellow/10 text-dt-yellow border border-dt-yellow/20"
              >MAINTENANCE</span
            >
          {:else}
            <span
              class="shrink-0 text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-surface-2 text-dt-text-muted border border-border"
              >PRÊT</span
            >
          {/if}

          <span class="w-32 shrink-0 text-[12px] text-dt-text-muted truncate">
            {truck.driver?.full_name ?? '—'}
          </span>
        </div>
      {/each}
    {/if}
  </div>
</div>

<style>
  .truck-node {
    animation: slide 2.5s ease-in-out infinite;
  }

  @keyframes slide {
    0% {
      left: 4%;
    }
    50% {
      left: 88%;
    }
    100% {
      left: 4%;
    }
  }
</style>
