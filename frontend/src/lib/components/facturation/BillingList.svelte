<script lang="ts">
  import {goto} from '$app/navigation';
  import {resolve} from '$app/paths';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import StatItem from '$lib/components/common/StatItem.svelte';
  import type {BillingStatement} from '$lib/types/billing';
  import type {Row} from '$lib/types/dataTable';
  import {formatMonth} from '$lib/utility/date';
  import {billingStatusMeta, billingStatusFilters} from '$lib/store/billingStatus';
  import {generateBillingStatement} from '$lib/api/billing';

  const formatAmount = (amount: number) => `${amount.toLocaleString('fr-FR')} GNF`;

  const borderClasses = (billing: BillingStatement) => {
    if (billing.status === 'issued') return 'border-l-4 border-l-accent';
    if (billing.status === 'paid') return 'border-l-4 border-l-dt-green';
    if (billing.status === 'void') return 'border-l-4 border-l-dt-red';
    return 'border-l-4 border-l-border';
  };

  const previousMonthValue = () => {
    const now = new Date();
    const prev = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    return `${prev.getFullYear()}-${String(prev.getMonth() + 1).padStart(2, '0')}`;
  };

  let table: ReturnType<typeof DataTable> | undefined = $state();
  let month = $state(previousMonthValue());
  let generating = $state(false);
  let generateError = $state<string | null>(null);

  const handleGenerate = async () => {
    generating = true;
    generateError = null;
    const {error} = await generateBillingStatement(`${month}-01`);
    generating = false;
    if (error) {
      generateError = error;
      return;
    }
    table?.refresh();
  };

  const openDetails = (billing: BillingStatement) =>
    goto(resolve('/(app)/facturation/[id]/details', {id: String(billing.id)}));
</script>

{#snippet generateAction()}
  <div class="flex items-center gap-2">
    {#if generateError}
      <span class="text-[12px] text-dt-red">{generateError}</span>
    {/if}
    <input
      type="month"
      bind:value={month}
      class="px-2.5 py-1.5 text-[13px] bg-surface border border-border rounded-lg text-dt-text focus:outline-none focus:ring-1 focus:ring-accent/40"
    />
    <button
      onclick={handleGenerate}
      disabled={generating}
      class="px-3 py-1.5 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms] disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {generating ? 'Génération…' : '+ Générer'}
    </button>
  </div>
{/snippet}

{#snippet billingCard(row: Row)}
  {@const billing = row as BillingStatement}
  <div
    role="button"
    tabindex="0"
    onclick={() => openDetails(billing)}
    onkeydown={(e) => (e.key === 'Enter' || e.key === ' ') && openDetails(billing)}
    class="rounded-lg border border-border bg-surface p-4 flex flex-col gap-3 cursor-pointer hover:border-accent/40 transition-colors duration-[130ms] {borderClasses(
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
  bind:this={table}
  endpoint="/billing_statements"
  filters={billingStatusFilters}
  card={billingCard}
  cardGridClasses="grid gap-3 sm:grid-cols-2 xl:grid-cols-3"
  actions={generateAction}
/>
