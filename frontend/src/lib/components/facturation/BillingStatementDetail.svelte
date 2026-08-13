<script lang="ts">
  import type {Snippet} from 'svelte';
  import {onMount} from 'svelte';
  import {resolve} from '$app/paths';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import Icon from '$lib/components/common/Icon.svelte';
  import type {BillingStatement} from '$lib/types/billing';
  import type {BillingLineItem} from '$lib/types/billingLineItem';
  import type {BillingLineItemColumnCell} from '$lib/types/billingLineItemColumns';
  import type {Row} from '$lib/types/dataTable';
  import {formatDate, formatMonth} from '$lib/utility/date';
  import {billingStatusMeta} from '$lib/store/billingStatus';
  import {billingLineItemColumns} from '$lib/store/billingLineItemColumns';
  import {getBillingStatement} from '$lib/api/billing';

  let {id}: {id: string} = $props();

  let statement = $state<BillingStatement | null>(null);
  let loading = $state(true);
  let error = $state<string | null>(null);

  const formatAmount = (amount: number) => `${amount.toLocaleString('fr-FR')} GNF`;

  onMount(async () => {
    const result = await getBillingStatement(id);
    statement = result.data;
    error = result.error;
    loading = false;
  });

  const cellRenderers: Record<BillingLineItemColumnCell, Snippet<[unknown, Row]>> = {
    date: dateCell,
    deliveryNoteNumber: deliveryNoteNumberCell,
    route: routeCell,
    gasoil: gasoilCell,
    essence: essenceCell,
    rate: rateCell,
    amount: amountCell,
    tva: tvaCell,
  };

  const columns = billingLineItemColumns.map((c) => ({
    key: c.key,
    label: c.label,
    render: cellRenderers[c.cell],
  }));
</script>

{#snippet dateCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {formatDate(item.startedOn)}
{/snippet}

{#snippet deliveryNoteNumberCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.deliveryNoteNumber ?? '—'}
{/snippet}

{#snippet routeCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.origin} → {item.destination}
{/snippet}

{#snippet gasoilCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.dieselQuantity.toLocaleString('fr-FR')}
{/snippet}

{#snippet essenceCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.gasolineQuantity.toLocaleString('fr-FR')}
{/snippet}

{#snippet rateCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.rate.toLocaleString('fr-FR')}
{/snippet}

{#snippet amountCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.amount.toLocaleString('fr-FR')}
{/snippet}

{#snippet tvaCell(_value: unknown, row: Row)}
  {@const item = row as BillingLineItem}
  {item.tva.toLocaleString('fr-FR')}
{/snippet}

<div class="flex flex-col gap-4">
  <a
    href={resolve('/facturation')}
    class="flex items-center gap-1.5 text-[13px] text-dt-text-muted hover:text-dt-text transition-colors w-fit"
  >
    <Icon name="chevron-left" size={14} />
    Retour à la facturation
  </a>

  {#if loading}
    <div class="h-6 w-40 rounded bg-surface animate-pulse"></div>
  {:else if error}
    <p class="text-dt-text-muted text-sm">{error}</p>
  {:else if statement}
    <div>
      <h1 class="text-xl font-bold text-dt-text">{formatMonth(statement.month)}</h1>
      <div class="flex items-center gap-2 mt-1.5">
        <span class="text-[12px] text-dt-text-muted font-mono">{statement.number}</span>
        <span
          class="inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-0.5 rounded-full border whitespace-nowrap {billingStatusMeta[
            statement.status
          ].classes}"
        >
          <span class="w-1.5 h-1.5 rounded-full bg-current"></span>
          {billingStatusMeta[statement.status].label}
        </span>
      </div>
      {#if statement.status === 'paid' && statement.paidOn}
        <div class="text-[12px] text-dt-text-muted mt-1.5">
          Payée le {formatDate(statement.paidOn)}
        </div>
      {/if}
    </div>

    <DataTable endpoint={`/billing_line_items?billing_statement_id=${id}`} {columns} />

    <div class="flex justify-end">
      <div class="w-full max-w-xs rounded-lg border border-border bg-surface overflow-hidden">
        <div class="flex flex-col gap-2.5 p-4">
          <div class="flex items-center justify-between gap-4 text-[13px]">
            <span class="text-dt-text-muted">Montant HT</span>
            <span class="text-dt-text font-medium">{formatAmount(statement.totalAmount)}</span>
          </div>
          <div class="flex items-center justify-between gap-4 text-[13px]">
            <span class="text-dt-text-muted">TVA (18%)</span>
            <span class="text-dt-text font-medium">{formatAmount(statement.totalTva)}</span>
          </div>
        </div>
        <div
          class="flex items-center justify-between gap-4 px-4 py-3 bg-accent/10 border-t border-accent/20"
        >
          <span class="text-[13px] font-bold text-accent uppercase tracking-wide">Total TTC</span>
          <span class="text-lg font-bold text-accent">{formatAmount(statement.grandTotal)}</span>
        </div>
      </div>
    </div>
  {/if}
</div>
