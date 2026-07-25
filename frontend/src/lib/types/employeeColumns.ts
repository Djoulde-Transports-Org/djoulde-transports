export type EmployeeColumnCell =
  | 'name'
  | 'role'
  | 'phone'
  | 'address'
  | 'hireDate'
  | 'status'
  | 'assignedTruck';

export type EmployeeColumn = {
  key: string;
  label: string;
  cell: EmployeeColumnCell;
};
