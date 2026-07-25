<script lang="ts">
  import type {Snippet} from 'svelte';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import EmployeeFormDrawer from '$lib/components/employes/EmployeeFormDrawer.svelte';
  import type {Employee} from '$lib/types/employee';
  import type {Row} from '$lib/types/dataTable';
  import {formatDate} from '$lib/utility/date';
  import {employeeRoleMeta, employeeRoleFilters} from '$lib/store/employeeRole';
  import {employeeStatusMeta} from '$lib/store/employeeStatus';
  import {employeeColumns} from '$lib/store/employeeColumns';
  import type {EmployeeColumnCell} from '$lib/types/employeeColumns';

  let table: ReturnType<typeof DataTable> | undefined = $state();
  let drawerOpen = $state(false);
  let editingEmployee = $state<Employee | null>(null);

  const openAddDrawer = () => {
    editingEmployee = null;
    drawerOpen = true;
  };

  const openEditDrawer = (row: Row) => {
    editingEmployee = row as Employee;
    drawerOpen = true;
  };

  const handleSaved = () => table?.refresh();

  const cellRenderers: Record<EmployeeColumnCell, Snippet<[unknown, Row]>> = {
    name: nameCell,
    role: roleCell,
    phone: phoneCell,
    address: addressCell,
    hireDate: hireDateCell,
    status: statusCell,
    assignedTruck: assignedTruckCell,
  };

  const columns = employeeColumns.map((c) => ({
    key: c.key,
    label: c.label,
    render: cellRenderers[c.cell],
  }));
</script>

{#snippet nameCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  <div class="font-bold text-dt-text">{employee.fullName}</div>
  <div class="text-[11px] text-dt-text-muted">ID {employee.id}</div>
{/snippet}

{#snippet roleCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  <span
    class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {employeeRoleMeta[employee.role]
      .classes}"
  >
    {employeeRoleMeta[employee.role].label}
  </span>
{/snippet}

{#snippet phoneCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  {employee.phoneNumber ?? '—'}
{/snippet}

{#snippet addressCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  {employee.address ?? '—'}
{/snippet}

{#snippet hireDateCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  {formatDate(employee.hireDate)}
{/snippet}

{#snippet statusCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  <span
    class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {employeeStatusMeta[
      employee.status
    ].classes}"
  >
    {employeeStatusMeta[employee.status].label}
  </span>
{/snippet}

{#snippet assignedTruckCell(_value: unknown, row: Row)}
  {@const employee = row as Employee}
  {employee.assignedTruck?.plateNumber ?? '—'}
{/snippet}

{#snippet addEmployeeAction()}
  <button
    onclick={openAddDrawer}
    class="px-3 py-1.5 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms]"
  >
    Ajouter un employé
  </button>
{/snippet}

<DataTable
  bind:this={table}
  endpoint="/employees?per_page=100"
  rowClickable
  actions={addEmployeeAction}
  onRowClick={openEditDrawer}
  clientSide
  filters={employeeRoleFilters}
  searchParam="search"
  searchFields={['fullName', 'id']}
  showAllCount
  {columns}
/>

<EmployeeFormDrawer
  open={drawerOpen}
  employee={editingEmployee}
  onClose={() => (drawerOpen = false)}
  onSaved={handleSaved}
/>
