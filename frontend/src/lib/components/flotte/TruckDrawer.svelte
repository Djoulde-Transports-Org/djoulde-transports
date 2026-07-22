<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import type {Truck} from '$lib/types/truck';
  import {formatDate} from '$lib/utility/date';
  import {expiryPill} from '$lib/utility/expiry';
  import {formatTruckModel, formatTankSummary, truckDocumentRows} from '$lib/utility/truck';
  import {truckStatusMeta} from '$lib/store/truckStatus';

  let {truck, onClose}: {truck: Truck | null; onClose: () => void} = $props();

  const initials = (fullName: string) =>
    fullName
      .split(' ')
      .map((part) => part[0])
      .filter(Boolean)
      .slice(0, 2)
      .join('')
      .toUpperCase();

  $effect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && truck) onClose();
    };
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  });
</script>

{#if truck}
  {@const t = truck}
  <div
    class="fixed inset-0 bg-ground/70 z-40"
    onclick={onClose}
    role="presentation"
    aria-hidden="true"
  ></div>

  <div
    class="fixed inset-y-0 right-0 z-50 w-[550px] max-w-[90vw] bg-surface border-l border-border flex flex-col"
    role="dialog"
    aria-modal="true"
    aria-label="Détails camion"
  >
    <div class="flex items-center justify-between px-5 py-4 border-b border-border">
      <div>
        <div class="text-[16px] font-bold font-mono text-dt-text">{t.plate_number}</div>
        <div class="text-[12px] text-dt-text-muted">{formatTruckModel(t)}</div>
      </div>
      <div class="flex items-center gap-3">
        <span
          class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {truckStatusMeta[t.status]
            .classes}"
        >
          {truckStatusMeta[t.status].label}
        </span>
        <button
          onclick={onClose}
          aria-label="Fermer"
          class="text-dt-text-muted hover:text-dt-text transition-colors duration-[130ms]"
        >
          <Icon name="x" size={18} />
        </button>
      </div>
    </div>

    <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-6">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <div class="text-[11px] text-dt-text-muted uppercase tracking-wider mb-1">
            Citerne · Capacité
          </div>
          <div class="text-[13px] text-dt-text font-medium">{formatTankSummary(t.tank)}</div>
        </div>
        <div>
          <div class="text-[11px] text-dt-text-muted uppercase tracking-wider mb-1">
            Dernière vidange
          </div>
          <div class="text-[13px] text-dt-text font-medium">
            {formatDate(t.last_oil_change_on)}
          </div>
        </div>
      </div>

      <div>
        <div class="text-[13px] font-semibold text-dt-text mb-2">Chauffeur assigné</div>
        {#if t.driver}
          <div class="flex items-center gap-3 bg-surface-2 border border-border rounded-lg p-3">
            <div
              class="w-9 h-9 rounded-full bg-accent/10 text-accent border border-accent/20 flex items-center justify-center text-[12px] font-bold shrink-0"
            >
              {initials(t.driver.full_name)}
            </div>
            <div class="min-w-0">
              <div class="text-[13px] font-medium text-dt-text truncate">{t.driver.full_name}</div>
              <div class="text-[12px] text-dt-text-muted flex items-center gap-2">
                <span>ID {t.driver.id}</span>
                {#if t.driver.phone_number}
                  <span class="flex items-center gap-1">
                    <Icon name="phone" size={11} />
                    {t.driver.phone_number}
                  </span>
                {/if}
              </div>
            </div>
          </div>
        {:else}
          <p class="text-[13px] text-dt-text-muted">Aucun chauffeur assigné.</p>
        {/if}
      </div>

      <div>
        <div class="text-[13px] font-semibold text-dt-text mb-2">Documents</div>
        <div class="flex flex-col divide-y divide-border-soft border border-border rounded-lg">
          {#each truckDocumentRows(t) as doc (doc.label)}
            {@const pill = expiryPill(doc.daysRemaining)}
            <div class="flex items-center justify-between px-3 py-2">
              <span class="text-[13px] text-dt-text">{doc.label}</span>
              <span
                class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}"
              >
                {pill.label}
              </span>
            </div>
          {/each}
        </div>
      </div>

      <div>
        <div class="text-[13px] font-semibold text-dt-text mb-2">Statistiques</div>
        <div class="grid grid-cols-3 gap-3">
          <div class="border border-border rounded-lg p-3 text-center">
            <div class="text-[18px] font-bold text-dt-text">{t.trips_count}</div>
            <div class="text-[10px] text-dt-text-muted uppercase tracking-wider mt-1">
              Trajets effectués
            </div>
          </div>
          <div class="border border-border rounded-lg p-3 text-center">
            <div class="text-[18px] font-bold text-dt-text">
              {t.total_km.toLocaleString('fr-FR')}
            </div>
            <div class="text-[10px] text-dt-text-muted uppercase tracking-wider mt-1">
              Km parcourus
            </div>
          </div>
          <div class="border border-border rounded-lg p-3 text-center">
            <div class="text-[18px] font-bold text-dt-text">
              {t.total_liters_delivered.toLocaleString('fr-FR')}
            </div>
            <div class="text-[10px] text-dt-text-muted uppercase tracking-wider mt-1">
              Litres livrés
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="px-5 py-4 border-t border-border">
      <button
        onclick={onClose}
        class="w-full px-4 py-2 text-[13px] font-medium rounded-lg border border-border text-dt-text hover:bg-surface-2 transition-colors duration-[130ms]"
      >
        Fermer
      </button>
    </div>
  </div>
{/if}
