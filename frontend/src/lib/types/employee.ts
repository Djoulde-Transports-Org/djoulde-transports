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

export type EmployeePayload = {
  firstName?: string;
  lastName?: string;
  phoneNumber?: string;
  address?: string;
  hireDate?: string;
  role?: string;
  status?: string;
  truckId?: number | null;
};

export type EmployeeFormValues = {
  firstName: string;
  lastName: string;
  role: string;
  phoneNumber: string;
  address: string;
  hireDate: string;
  status: string;
  truckId: string;
};
