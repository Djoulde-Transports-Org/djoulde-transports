<script lang="ts">
  const TVA_RATE = 0.18;

  let {rate, totalLiters}: {rate: number | null; totalLiters: number} = $props();

  const ht = $derived(rate ? Math.round(rate * totalLiters) : 0);
  const tva = $derived(Math.round(ht * TVA_RATE));
  const ttc = $derived(ht + tva);

  const formatAmount = (amount: number) => `${amount.toLocaleString('fr-FR')} GNF`;
</script>

{#snippet stat(
  label: string,
  value: string,
  valueClass = 'text-[13px] font-medium text-dt-text',
  align = ''
)}
  <div class={align}>
    <div class="text-[11px] text-dt-text-muted uppercase tracking-wider">{label}</div>
    <div class={valueClass}>{value}</div>
  </div>
{/snippet}

{#if rate && totalLiters > 0}
  <div
    class="flex items-center justify-between gap-3 bg-surface-2 border border-border rounded-lg p-3"
    data-testid="billing-preview"
  >
    {@render stat('HT', formatAmount(ht))}
    {@render stat('TVA (18%)', formatAmount(tva))}
    {@render stat(
      'Total TTC',
      formatAmount(ttc),
      'text-[14px] font-bold text-accent',
      'text-right'
    )}
  </div>
{/if}
