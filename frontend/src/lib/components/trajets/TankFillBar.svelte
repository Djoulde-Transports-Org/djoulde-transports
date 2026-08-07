<script lang="ts">
  type FillState = 'empty' | 'partial' | 'exact' | 'over' | null;

  let {
    capacity,
    dieselQuantity,
    gasolineQuantity,
  }: {capacity: number | null; dieselQuantity: number; gasolineQuantity: number} = $props();

  const total = $derived(dieselQuantity + gasolineQuantity);

  const state = $derived.by((): FillState => {
    if (!capacity) return null;
    if (total === 0) return 'empty';
    if (total < capacity) return 'partial';
    if (total === capacity) return 'exact';
    return 'over';
  });

  const segmentPct = (quantity: number) => {
    if (!capacity || total === 0) return 0;
    return (quantity / (state === 'over' ? total : capacity)) * 100;
  };

  const dieselPct = $derived(segmentPct(dieselQuantity));
  const gasolinePct = $derived(segmentPct(gasolineQuantity));

  const remaining = $derived(capacity ? capacity - total : 0);

  const message = $derived.by(() => {
    switch (state) {
      case 'empty':
        return 'Renseignez les quantités pour visualiser le remplissage';
      case 'partial':
        return `${remaining.toLocaleString('fr-FR')} L restants`;
      case 'exact':
        return 'Citerne remplie exactement';
      case 'over':
        return `Dépassement de ${Math.abs(remaining).toLocaleString('fr-FR')} L`;
      default:
        return '';
    }
  });

  const messageClasses = $derived(
    {
      empty: 'text-dt-text-muted',
      partial: 'text-dt-yellow',
      exact: 'text-dt-green',
      over: 'text-dt-red',
    }[state ?? 'empty']
  );

  const trackClasses = $derived(state === 'over' ? 'border-dt-red/40' : 'border-border');
</script>

{#if capacity}
  <div class="flex flex-col gap-2" data-testid="tank-fill-bar">
    <div
      class="flex items-center justify-between text-[11px] text-dt-text-muted uppercase tracking-wider"
    >
      <span>Remplissage de la citerne</span>
      <span class="text-dt-text">{capacity.toLocaleString('fr-FR')} L</span>
    </div>
    <div class="h-2.5 rounded-full bg-surface-2 border {trackClasses} overflow-hidden flex">
      <div
        class="h-full bg-accent transition-[width] duration-150"
        style="width: {dieselPct}%"
      ></div>
      <div
        class="h-full bg-brand-blue transition-[width] duration-150"
        style="width: {gasolinePct}%"
      ></div>
    </div>
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3 text-[11px] text-dt-text-muted">
        <span class="flex items-center gap-1">
          <span class="w-2 h-2 rounded-full bg-accent"></span>Gasoil
        </span>
        <span class="flex items-center gap-1">
          <span class="w-2 h-2 rounded-full bg-brand-blue"></span>Essence
        </span>
      </div>
      <span class="text-[12px] font-medium {messageClasses}">{message}</span>
    </div>
  </div>
{/if}
