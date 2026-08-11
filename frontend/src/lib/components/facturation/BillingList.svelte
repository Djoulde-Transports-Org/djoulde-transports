<script lang="ts">
  import DataTable from '$lib/components/common/DataTable.svelte';
  import StatItem from '$lib/components/common/StatItem.svelte';
  import type {BillingStatement} from '$lib/types/billing';
  import type {Row} from '$lib/types/dataTable';
  import {formatMonth} from '$lib/utility/date';
  import {billingStatusMeta, billingStatusFilters} from '$lib/store/billingStatus';

  const formatAmount = (amount: number) => `${amount.toLocaleString('fr-FR')} GNF`;

  const borderClasses = (billing: BillingStatement) => {
    if (billing.status === 'issued') return 'border-l-4 border-l-accent';
    if (billing.status === 'paid') return 'border-l-4 border-l-dt-green';
    if (billing.status === 'void') return 'border-l-4 border-l-dt-red';
    return 'border-l-4 border-l-border';
  };
</script>

{#snippet billingCard(row: Row)}
  {@const billing = row as BillingStatement}
  <div
    class="rounded-lg border border-border bg-surface p-4 flex flex-col gap-3 {borderClasses(
      billing
    )}"
  >
    <div class="flex items-start justify-between gap-2">
      <div>
        <div class="font-bold text-dt-text">{formatMonth(billing.month)}</div>
        <div class="text-[12px] text-dt-text-muted font-mono">{billing.number}</div>
      </div>
      <span
        class="inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-0.5 rounded-full border whitespace-nowrap {billingStatusMeta[
          billing.status
        ].classes}"
      >
        <span class="w-1.5 h-1.5 rounded-full bg-current"></span>
        {billingStatusMeta[billing.status].label}
      </span>
    </div>

    <div class="grid grid-cols-3 gap-2 text-[12px]">
      <StatItem label="HT" value={formatAmount(billing.totalAmount)} />
      <StatItem label="TVA" value={formatAmount(billing.totalTva)} />
      <StatItem label="TTC" value={formatAmount(billing.grandTotal)} emphasize />
    </div>
  </div>
{/snippet}

<DataTable
  endpoint="/billing_statements"
  filters={billingStatusFilters}
  card={billingCard}
  cardGridClasses="grid gap-3 sm:grid-cols-2 xl:grid-cols-3"
/>
