<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import Form from '$lib/components/common/Form.svelte';
  import Combobox from '$lib/components/common/Combobox.svelte';
  import TankFillBar from '$lib/components/trajets/TankFillBar.svelte';
  import BillingPreview from '$lib/components/trajets/BillingPreview.svelte';
  import {getEmployees} from '$lib/api/employees';
  import {getAllTrucks} from '$lib/api/trucks';
  import {getRoutes, getRouteOrigins} from '$lib/api/routes';
  import {createTrip} from '$lib/api/trips';
  import type {Employee} from '$lib/types/employee';
  import type {Truck} from '$lib/types/truck';
  import type {Route} from '$lib/types/route';
  import type {CreateTripPayload, NewTripValues} from '$lib/types/trip';
  import {newTripSchema} from '$lib/store/newTrip';
  import {formatTruckModel, formatTankSummary} from '$lib/utility/truck';
  import {compact} from '$lib/utility/object';

  let {open, onClose, onCreated}: {open: boolean; onClose: () => void; onCreated: () => void} =
    $props();

  let trucks = $state<Truck[]>([]);
  let origins = $state<string[]>([]);
  let destinationRoutes = $state<Route[]>([]);
  let drivers = $state<Employee[]>([]);
  let apiError = $state<string | null>(null);
  let truckId = $state('');
  let origin = $state('');
  let destination = $state('');
  let dieselQuantity = $state('');
  let gasolineQuantity = $state('');

  const selectedTruck = $derived(trucks.find((t) => t.id === Number(truckId)) ?? null);

  const originOptions = $derived(origins.map((o) => ({value: o, label: o})));

  const destinationOptions = $derived(
    destinationRoutes.map((r) => ({value: r.destination, label: r.destination}))
  );

  const selectedRoute = $derived(
    destinationRoutes.find((r) => r.destination === destination) ?? null
  );

  const totalLiters = $derived((Number(dieselQuantity) || 0) + (Number(gasolineQuantity) || 0));

  const loadOptions = async () => {
    const [truckRes, originsRes, driverRes] = await Promise.all([
      getAllTrucks(),
      getRouteOrigins(),
      getEmployees('driver'),
    ]);
    trucks = truckRes.data;
    origins = originsRes.data;
    drivers = driverRes.data;
  };

  $effect(() => {
    if (open) {
      apiError = null;
      truckId = '';
      origin = '';
      destination = '';
      dieselQuantity = '';
      gasolineQuantity = '';
      destinationRoutes = [];
      loadOptions();
    }
  });

  $effect(() => {
    if (!origin) {
      destinationRoutes = [];
      return;
    }
    getRoutes(100, origin).then((res) => {
      destinationRoutes = res.data;
    });
  });

  $effect(() => {
    if (!destinationOptions.some((option) => option.value === destination)) {
      destination = '';
    }
  });

  $effect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && open) onClose();
    };
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  });

  const handleSubmit = async (values: NewTripValues) => {
    apiError = null;
    const payload: CreateTripPayload = {
      truckId: Number(values.truckId),
      routeId: Number(values.routeId),
      ...compact({
        driverId: values.driverId ? Number(values.driverId) : undefined,
        scheduledStartAt: values.scheduledStartAt,
        scheduledEndAt: values.scheduledEndAt,
      }),
      deliveryNote: {
        number: values.deliveryNoteNumber,
        ...compact({
          gasolineQuantity: values.gasolineQuantity ? Number(values.gasolineQuantity) : undefined,
          dieselQuantity: values.dieselQuantity ? Number(values.dieselQuantity) : undefined,
        }),
      },
    };

    const {data, error} = await createTrip(payload);

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

{#snippet sectionHeader(num: string, title: string, optional = false)}
  <div class="flex items-center gap-2 mb-3">
    <span
      class="text-[11px] font-bold text-accent bg-accent/10 border border-accent/20 rounded px-1.5 py-0.5"
    >
      {num}
    </span>
    <span class="text-[13px] font-bold text-dt-text uppercase tracking-wide">{title}</span>
    {#if optional}
      <span class="text-[12px] text-dt-text-muted">(optionnel)</span>
    {/if}
  </div>
{/snippet}

{#snippet field(
  id: string,
  label: string,
  error: string | null | undefined,
  type = 'text',
  oninput: (event: Event) => void = () => {}
)}
  <div>
    <label
      for={id}
      class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {error
        ? 'text-dt-red'
        : ''}"
    >
      {label}
    </label>
    <input
      {id}
      name={id}
      {type}
      {oninput}
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
    aria-label="Nouveau trajet"
  >
    <div class="flex items-center justify-between px-5 py-4 border-b border-border">
      <div class="text-[16px] font-bold text-dt-text">Nouveau trajet</div>
      <button
        onclick={onClose}
        aria-label="Fermer"
        class="text-dt-text-muted hover:text-dt-text transition-colors duration-[130ms]"
      >
        <Icon name="x" size={18} />
      </button>
    </div>

    <Form
      id="new-trip"
      schema={newTripSchema}
      onSubmit={handleSubmit}
      class="flex-1 flex flex-col min-h-0"
    >
      {#snippet children({errors, isValid, isSubmitting})}
        <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-6">
          <div>
            {@render sectionHeader('01', 'Convoi')}
            <div class="flex flex-col gap-3">
              <Combobox
                id="truckId"
                name="truckId"
                label="Camion"
                options={trucks.map((t) => ({value: t.id, label: t.plateNumber}))}
                bind:value={truckId}
                error={errors.truckId}
              />
              {#if selectedTruck}
                <div
                  class="flex items-center gap-3 bg-surface-2 border border-border rounded-lg p-3"
                >
                  <div class="min-w-0">
                    <div class="text-[13px] font-medium text-dt-text truncate">
                      {selectedTruck.plateNumber}
                    </div>
                    <div class="text-[12px] text-dt-text-muted truncate">
                      {formatTruckModel(selectedTruck)}
                    </div>
                  </div>
                  <div class="ml-auto text-right shrink-0">
                    <div class="text-[13px] font-medium text-dt-text">
                      {formatTankSummary(selectedTruck.tank)}
                    </div>
                    <div class="text-[11px] text-dt-text-muted">Citerne appairée</div>
                  </div>
                </div>
              {/if}
            </div>
          </div>

          <div>
            {@render sectionHeader('02', 'Itinéraire')}
            <div class="flex flex-col gap-3">
              <input type="hidden" name="routeId" value={selectedRoute?.id ?? ''} />
              <div class="grid grid-cols-2 gap-4">
                <Combobox
                  id="origin"
                  name="origin"
                  label="Origine"
                  options={originOptions}
                  bind:value={origin}
                />
                <Combobox
                  id="destination"
                  name="destination"
                  label="Destination"
                  options={destinationOptions}
                  bind:value={destination}
                  emptyLabel={origin ? 'Aucune sélection' : "Sélectionnez d'abord l'origine"}
                  error={errors.routeId}
                />
              </div>
              {#if selectedRoute}
                <p class="text-[12px] text-dt-text-muted">
                  Tarif : <span class="text-dt-text font-medium"
                    >{selectedRoute.rate.toLocaleString('fr-FR')} / L</span
                  >
                </p>
              {/if}
              <div class="grid grid-cols-2 gap-4">
                {@render field(
                  'scheduledStartAt',
                  'Départ',
                  errors.scheduledStartAt,
                  'datetime-local'
                )}
                {@render field(
                  'scheduledEndAt',
                  'Arrivée',
                  errors.scheduledEndAt,
                  'datetime-local'
                )}
              </div>
            </div>
          </div>

          <div>
            {@render sectionHeader('03', 'Chauffeur', true)}
            <div class="flex flex-col gap-2">
              <Combobox
                id="driverId"
                name="driverId"
                label="Affectation"
                options={drivers.map((driver) => ({value: driver.id, label: driver.fullName}))}
                emptyLabel="Non affecté pour l'instant"
                error={errors.driverId}
              />
              {#if selectedTruck?.driver}
                <p class="text-[12px] text-dt-text-muted">
                  Chauffeur habituel :
                  <span class="text-dt-text font-medium">{selectedTruck.driver.fullName}</span>
                  — assigné automatiquement si laissé vide.
                </p>
              {/if}
            </div>
          </div>

          <div>
            {@render sectionHeader('04', 'Bon de livraison')}
            <div class="flex flex-col gap-4">
              {@render field('deliveryNoteNumber', 'Numéro', errors.deliveryNoteNumber)}
              <div class="grid grid-cols-2 gap-4">
                {@render field(
                  'dieselQuantity',
                  'Gasoil (L)',
                  errors.dieselQuantity,
                  'number',
                  (e) => (dieselQuantity = (e.currentTarget as HTMLInputElement).value)
                )}
                {@render field(
                  'gasolineQuantity',
                  'Essence (L)',
                  errors.gasolineQuantity,
                  'number',
                  (e) => (gasolineQuantity = (e.currentTarget as HTMLInputElement).value)
                )}
              </div>
              <TankFillBar
                capacity={selectedTruck?.tank?.capacity ?? null}
                dieselQuantity={Number(dieselQuantity) || 0}
                gasolineQuantity={Number(gasolineQuantity) || 0}
              />
              <BillingPreview rate={selectedRoute?.rate ?? null} {totalLiters} />
            </div>
          </div>

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
            {isSubmitting ? 'Création...' : 'Créer le trajet'}
          </button>
        </div>
      {/snippet}
    </Form>
  </div>
{/if}
