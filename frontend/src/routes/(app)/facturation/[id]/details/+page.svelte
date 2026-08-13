<script lang="ts">
  import type {PageProps} from './$types';
  import BillingStatementDetail from '$lib/components/facturation/BillingStatementDetail.svelte';

  let {params}: PageProps = $props();
</script>

<div class="p-8">
  <BillingStatementDetail id={params.id} />
</div>
