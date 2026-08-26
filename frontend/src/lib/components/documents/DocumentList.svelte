<script lang="ts">
  import type {Snippet} from 'svelte';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import Icon from '$lib/components/common/Icon.svelte';
  import NewDocumentDrawer from '$lib/components/documents/NewDocumentDrawer.svelte';
  import type {FleetDocument} from '$lib/types/document';
  import type {Row} from '$lib/types/dataTable';
  import {formatDate} from '$lib/utility/date';
  import {docTypeLabel} from '$lib/store/documentType';
  import {documentableTypeLabel, documentEntityFilters} from '$lib/store/documentableType';
  import {documentColumns} from '$lib/store/documentColumns';
  import type {DocumentColumnCell} from '$lib/types/documentColumns';

  let table: ReturnType<typeof DataTable> | undefined = $state();
  let drawerOpen = $state(false);

  const handleCreated = () => table?.refresh();

  const cellRenderers: Record<DocumentColumnCell, Snippet<[unknown, Row]>> = {
    name: nameCell,
    number: numberCell,
    category: categoryCell,
    entity: entityCell,
    issuedOn: issuedOnCell,
    uploadDate: uploadDateCell,
    expiresOn: expiresOnCell,
    addedBy: addedByCell,
    fileAttached: fileAttachedCell,
  };

  const columns = documentColumns.map((c) => ({
    key: c.key,
    label: c.label,
    render: cellRenderers[c.cell],
  }));
</script>

{#snippet nameCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  <span class="font-bold text-dt-text">{doc.title}</span>
{/snippet}

{#snippet numberCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  <span class="font-mono text-dt-text-muted">{doc.number}</span>
{/snippet}

{#snippet categoryCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  <span
    class="text-[11px] font-medium px-2 py-0.5 rounded-full border bg-surface-2 text-dt-text-mid border-border"
  >
    {docTypeLabel(doc.docType)}
  </span>
{/snippet}

{#snippet entityCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  {documentableTypeLabel(doc.documentableType)} #{doc.documentableId}
{/snippet}

{#snippet issuedOnCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  {formatDate(doc.issuedOn)}
{/snippet}

{#snippet uploadDateCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  {formatDate(doc.createdAt)}
{/snippet}

{#snippet expiresOnCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  {formatDate(doc.expiresOn)}
{/snippet}

{#snippet addedByCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  {doc.uploadedBy?.name ?? '—'}
{/snippet}

{#snippet fileAttachedCell(_value: unknown, row: Row)}
  {@const doc = row as FleetDocument}
  {#if doc.fileAttached}
    <Icon name="check" size={14} class="text-dt-green" />
  {:else}
    <span class="text-dt-text-muted">—</span>
  {/if}
{/snippet}

{#snippet addDocumentAction()}
  <button
    onclick={() => (drawerOpen = true)}
    class="px-3 py-1.5 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms]"
  >
    + Ajouter un document
  </button>
{/snippet}

<DataTable
  bind:this={table}
  endpoint="/documents"
  paginated
  actions={addDocumentAction}
  filters={documentEntityFilters}
  searchParam="search"
  {columns}
/>

<NewDocumentDrawer
  open={drawerOpen}
  onClose={() => (drawerOpen = false)}
  onCreated={handleCreated}
/>
