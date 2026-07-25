import type {EmployeeStatus} from '$lib/types/employee';

export const employeeStatusMeta: Record<EmployeeStatus, {label: string; classes: string}> = {
  active: {label: 'Actif', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
  on_leave: {label: 'En congé', classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20'},
  inactive: {label: 'Inactif', classes: 'bg-surface-2 text-dt-text-muted border-border'},
};
