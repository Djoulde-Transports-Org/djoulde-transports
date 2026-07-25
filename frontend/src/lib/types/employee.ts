export type EmployeeRole = 'driver' | 'mechanic' | 'dispatcher' | 'manager';

export type EmployeeStatus = 'active' | 'on_leave' | 'inactive';

export type AssignedTruck = {
  id: number;
  plateNumber: string;
};

export type Employee = {
  id: number;
  firstName: string;
  lastName: string;
  fullName: string;
  phoneNumber: string | null;
  address: string | null;
  hireDate: string | null;
  role: EmployeeRole;
  status: EmployeeStatus;
  userId: number | null;
  assignedTruck: AssignedTruck | null;
};
