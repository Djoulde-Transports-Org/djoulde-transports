import type {EmployeeColumn} from '$lib/types/employeeColumns';

export const employeeColumns: EmployeeColumn[] = [
  {key: 'fullName', label: 'Nom', cell: 'name'},
  {key: 'role', label: 'Rôle', cell: 'role'},
  {key: 'phoneNumber', label: 'Téléphone', cell: 'phone'},
  {key: 'address', label: 'Adresse', cell: 'address'},
  {key: 'hireDate', label: "Date d'embauche", cell: 'hireDate'},
  {key: 'status', label: 'Statut', cell: 'status'},
  {key: 'assignedTruck', label: 'Camion assigné', cell: 'assignedTruck'},
];
