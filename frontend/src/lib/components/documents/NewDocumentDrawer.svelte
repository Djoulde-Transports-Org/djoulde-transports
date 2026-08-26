<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import Form from '$lib/components/common/Form.svelte';
  import Select from '$lib/components/common/Select.svelte';
  import Combobox from '$lib/components/common/Combobox.svelte';
  import {createDocument} from '$lib/api/documents';
  import {getAllTrucks} from '$lib/api/trucks';
  import {getAllTanks} from '$lib/api/tanks';
  import {getTrips} from '$lib/api/trips';
  import {getMaintenances} from '$lib/api/maintenances';
  import {getAllEmployees} from '$lib/api/employees';
  import {getBillingStatements} from '$lib/api/billing';
  import type {Truck, TruckTank} from '$lib/types/truck';
  import type {Trip} from '$lib/types/trip';
  import type {Maintenance} from '$lib/types/maintenance';
  import type {Employee} from '$lib/types/employee';
  import type {BillingStatement} from '$lib/types/billing';
  import type {DocumentableType, DocType, NewDocumentValues} from '$lib/types/document';
  import {
    newDocumentSchema,
    ACCEPTED_DOCUMENT_FILE_TYPES,
    MAX_DOCUMENT_FILE_SIZE,
  } from '$lib/store/newDocument';
  import {documentableTypeOptions} from '$lib/store/documentableType';
  import {docTypeLabels} from '$lib/store/documentType';
  import {maintenanceKindLabel} from '$lib/store/maintenanceKind';
  import {formatDate, formatMonth} from '$lib/utility/date';

  let {open, onClose, onCreated}: {open: boolean; onClose: () => void; onCreated: () => void} =
    $props();

  let documentableType = $state<DocumentableType | ''>('');
  let documentableId = $state('');
  let apiError = $state<string | null>(null);
  let fileName = $state<string | null>(null);

  const onFileChange = (event: Event) => {
    fileName = (event.currentTarget as HTMLInputElement).files?.[0]?.name ?? null;
  };

  let trucks = $state<Truck[]>([]);
  let tanks = $state<TruckTank[]>([]);
  let trips = $state<Trip[]>([]);
  let maintenances = $state<Maintenance[]>([]);
  let employees = $state<Employee[]>([]);
  let billingStatements = $state<BillingStatement[]>([]);

  const docTypeOptions = Object.entries(docTypeLabels).map(([value, label]) => ({value, label}));
  const maxFileSizeMb = MAX_DOCUMENT_FILE_SIZE / (1024 * 1024);

  const tripLabel = (trip: Trip) =>
    `#TRJ-${String(trip.id).padStart(4, '0')} — ${trip.route.origin} → ${trip.route.destination}`;

  const maintenanceLabel = (maintenance: Maintenance) =>
    `${maintenance.truck.plateNumber} — ${maintenanceKindLabel(maintenance.kind)} (${formatDate(maintenance.performedOn)})`;

  const billingStatementLabel = (statement: BillingStatement) =>
    `${statement.number} — ${formatMonth(statement.month)}`;

  const entityOptions = $derived.by(() => {
    switch (documentableType) {
      case 'Truck':
        return trucks.map((t) => ({value: t.id, label: t.plateNumber}));
      case 'Tank':
        return tanks.map((t) => ({value: t.id, label: t.plateNumber}));
      case 'Trip':
        return trips.map((t) => ({value: t.id, label: tripLabel(t)}));
      case 'Maintenance':
        return maintenances.map((m) => ({value: m.id, label: maintenanceLabel(m)}));
      case 'Employee':
        return employees.map((e) => ({value: e.id, label: e.fullName}));
      case 'BillingStatement':
        return billingStatements.map((b) => ({value: b.id, label: billingStatementLabel(b)}));
      default:
        return [];
    }
  });

  const loadEntities = async (type: DocumentableType | '') => {
    if (type === 'Truck') trucks = (await getAllTrucks()).data;
    else if (type === 'Tank') tanks = (await getAllTanks()).data;
    else if (type === 'Trip') trips = (await getTrips(100)).data;
    else if (type === 'Maintenance') maintenances = (await getMaintenances(100)).data;
    else if (type === 'Employee') employees = (await getAllEmployees()).data;
    else if (type === 'BillingStatement') billingStatements = (await getBillingStatements()).data;
  };

  $effect(() => {
    loadEntities(documentableType);
  });

  $effect(() => {
    if (!entityOptions.some((option) => option.value === Number(documentableId))) {
      documentableId = '';
    }
  });

  $effect(() => {
    if (open) {
      apiError = null;
      fileName = null;
      documentableType = '';
      documentableId = '';
      trucks = [];
      tanks = [];
      trips = [];
      maintenances = [];
      employees = [];
      billingStatements = [];
    }
  });

  $effect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && open) onClose();
    };
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  });

  const handleSubmit = async (values: NewDocumentValues) => {
    apiError = null;
    const {data, error} = await createDocument({
      documentableType: values.documentableType as DocumentableType,
      documentableId: Number(values.documentableId),
      number: values.number,
      title: values.title,
      docType: values.docType ? (values.docType as DocType) : undefined,
      issuedOn: values.issuedOn,
      expiresOn: values.expiresOn || undefined,
      file: values.file,
    });

    if (error) {
      apiError = error;
      return;
    }

    if (data) {
      onCreated();
      onClose();
    }
  };
</script>

{#snippet field(
  id: string,
  label: string,
  error: string | null | undefined,
  type = 'text',
  optional = false
)}
  <div>
    <label
      for={id}
      class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {error
        ? 'text-dt-red'
        : ''}"
    >
      {label}{optional ? ' (optionnel)' : ''}
    </label>
    <input
      {id}
      name={id}
      {type}
      class="w-full px-3 py-2 text-[13px] rounded-lg border bg-surface text-dt-text focus:outline-none focus:ring-1 transition-colors
        {error ? 'border-dt-red focus:ring-dt-red/40' : 'border-border focus:ring-accent/40'}"
    />
    {#if error}
      <p class="mt-1 text-[11px] text-dt-red">{error}</p>
    {/if}
  </div>
{/snippet}

{#if open}
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
    aria-label="Ajouter un document"
  >
    <div class="flex items-center justify-between px-5 py-4 border-b border-border">
      <div class="text-[16px] font-bold text-dt-text">Ajouter un document</div>
      <button
        onclick={onClose}
        aria-label="Fermer"
        class="text-dt-text-muted hover:text-dt-text transition-colors duration-[130ms]"
      >
        <Icon name="x" size={18} />
      </button>
    </div>

    <Form
      id="new-document"
      schema={newDocumentSchema}
      onSubmit={handleSubmit}
      class="flex-1 flex flex-col min-h-0"
    >
      {#snippet children({errors, isValid, isSubmitting})}
        <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-4">
          <div>
            <label
              for="file"
              class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {errors.file
                ? 'text-dt-red'
                : ''}"
            >
              Fichier
            </label>
            <div
              class="relative w-full px-3 py-2 rounded-lg border bg-surface focus-within:ring-1 transition-colors
                {errors.file
                ? 'border-dt-red focus-within:ring-dt-red/40'
                : 'border-border focus-within:ring-accent/40'}"
            >
              <div class="flex items-center gap-3 pointer-events-none">
                <span
                  class="px-3 py-1 rounded-md text-[12px] font-medium bg-surface-2 text-dt-text"
                >
                  Choisir un fichier
                </span>
                <span class="text-[13px] {fileName ? 'text-dt-text' : 'text-dt-text-muted'}">
                  {fileName ?? 'Aucun fichier sélectionné'}
                </span>
              </div>
              <input
                id="file"
                name="file"
                type="file"
                accept={ACCEPTED_DOCUMENT_FILE_TYPES.join(',')}
                oninput={onFileChange}
                class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
              />
            </div>
            <p class="mt-1 text-[11px] text-dt-text-muted">
              PDF, image, Word ou Excel, {maxFileSizeMb} Mo maximum.
            </p>
            {#if errors.file}
              <p class="mt-1 text-[11px] text-dt-red">{errors.file}</p>
            {/if}
          </div>

          {@render field('title', 'Nom du document', errors.title)}
          <div>
            {@render field('number', 'Numéro', errors.number, 'text', true)}
            <p class="mt-1 text-[11px] text-dt-text-muted">
              Généré automatiquement (DT-…) si laissé vide.
            </p>
          </div>

          <div class="grid grid-cols-2 gap-4">
            {@render field('issuedOn', "Date d'émission", errors.issuedOn, 'date')}
            {@render field('expiresOn', "Date d'expiration", errors.expiresOn, 'date', true)}
          </div>

          <Select
            id="documentableType"
            name="documentableType"
            label="Catégorie"
            options={documentableTypeOptions}
            bind:value={documentableType}
            error={errors.documentableType}
          />

          <Combobox
            id="documentableId"
            name="documentableId"
            label="Lié à"
            options={entityOptions}
            bind:value={documentableId}
            emptyLabel={documentableType
              ? 'Sélectionner une entité'
              : "Choisir d'abord une catégorie"}
            error={errors.documentableId}
          />

          <Select
            id="docType"
            name="docType"
            label="Type de document (optionnel)"
            options={docTypeOptions}
            placeholder="Sélectionner un type"
            error={errors.docType}
          />

          {#if apiError}
            <p class="text-[13px] text-dt-red">{apiError}</p>
          {/if}
        </div>

        <div class="px-5 py-4 border-t border-border flex gap-3">
          <button
            type="button"
            onclick={onClose}
            class="flex-1 px-4 py-2 text-[13px] font-medium rounded-lg border border-border text-dt-text hover:bg-surface-2 transition-colors duration-[130ms]"
          >
            Annuler
          </button>
          <button
            type="submit"
            disabled={!isValid || isSubmitting}
            class="flex-1 px-4 py-2 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms] disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSubmitting ? 'Ajout...' : 'Ajouter le document'}
          </button>
        </div>
      {/snippet}
    </Form>
  </div>
{/if}
