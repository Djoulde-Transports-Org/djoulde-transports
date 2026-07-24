export type TruckStatus = 'ready' | 'on_trip' | 'in_maintenance';

export type TruckStatusOption = {
  value: TruckStatus;
  label: string;
};

export type TruckDriver = {
  id: number;
  firstName: string;
  lastName: string;
  fullName: string;
  phoneNumber: string | null;
  role: string;
  userId: number | null;
};

export type TruckTank = {
  id: number;
  truckId: number;
  plateNumber: string;
  vin: string | null;
  make: string | null;
  model: string | null;
  year: number | null;
  capacity: number;
  status: string;
  conformityCertificateExpiresOn: string | null;
  conformityCertificateDaysRemaining: number | null;
};

export type Truck = {
  id: number;
  plateNumber: string;
  vin: string | null;
  make: string | null;
  model: string | null;
  year: number | null;
  status: TruckStatus;
  createdById: number;
  tank: TruckTank | null;
  driver: TruckDriver | null;
  lastOilChangeOn: string | null;
  truckInsuranceExpiresOn: string | null;
  truckInsuranceDaysRemaining: number | null;
  cargoInsuranceExpiresOn: string | null;
  cargoInsuranceDaysRemaining: number | null;
  technicalInspectionExpiresOn: string | null;
  technicalInspectionDaysRemaining: number | null;
  operatingPermitExpiresOn: string | null;
  operatingPermitDaysRemaining: number | null;
  truckRegistrationExpiresOn: string | null;
  truckRegistrationDaysRemaining: number | null;
  tripsCount: number;
  totalKm: number;
  totalLitersDelivered: number;
};

export type CreateTruckPayload = {
  plateNumber: string;
  vin?: string;
  make?: string;
  model: string;
  year: number;
  status?: string;
  driverId?: number;
  lastOilChangeOn?: string;
  tank: {
    plateNumber: string;
    capacity: number;
    vin?: string;
    make?: string;
    model?: string;
    year?: number;
  };
  documents?: {
    truckInsuranceExpiresOn?: string;
    cargoInsuranceExpiresOn?: string;
    technicalInspectionExpiresOn?: string;
    operatingPermitExpiresOn?: string;
    truckRegistrationExpiresOn?: string;
  };
};

export type AddTruckValues = {
  plateNumber: string;
  vin: string;
  make: string;
  model: string;
  year: string;
  status: string;
  tankPlateNumber: string;
  tankCapacity: string;
  tankMake: string;
  tankModel: string;
  tankVin: string;
  tankYear: string;
  driverId: string;
  lastOilChangeOn: string;
  truckInsuranceExpiresOn: string;
  cargoInsuranceExpiresOn: string;
  technicalInspectionExpiresOn: string;
  operatingPermitExpiresOn: string;
  truckRegistrationExpiresOn: string;
};
