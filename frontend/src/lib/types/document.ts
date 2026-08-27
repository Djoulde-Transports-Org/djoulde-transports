export type DocumentableType =
  | 'Truck'
  | 'Tank'
  | 'Trip'
  | 'Maintenance'
  | 'BillingStatement'
  | 'Employee';

export type DocType =
  | 'other'
  | 'truck_insurance'
  | 'product_insurance'
  | 'driver_license'
  | 'driver_insurance'
  | 'technical_inspection'
  | 'loading_certificate'
  | 'conformity_certificate'
  | 'transport_card'
  | 'truck_registration'
  | 'invoice'
  | 'delivery_note'
  | 'maintenance_note';

export type DocumentUploadedBy = {
  id: number;
  name: string;
};

export type FleetDocument = {
  id: number;
  documentableType: DocumentableType;
  documentableId: number;
  documentableLabel: string | null;
  documentableDate: string | null;
  docType: DocType;
  number: string;
  title: string;
  issuedOn: string | null;
  expiresOn: string | null;
  uploadedById: number | null;
  uploadedBy: DocumentUploadedBy | null;
  fileAttached: boolean;
  fileSize: number | null;
  createdAt: string;
};

export type NewDocumentValues = {
  title: string;
  number: string;
  documentableType: string;
  documentableId: string;
  docType: string;
  issuedOn: string;
  expiresOn: string;
  file: File;
};
