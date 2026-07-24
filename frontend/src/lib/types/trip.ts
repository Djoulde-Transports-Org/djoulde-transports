import type {Truck, TruckDriver} from './truck';

export type TripStatus = 'scheduled' | 'in_progress' | 'completed' | 'cancelled';

export type TripRoute = {
  id: number;
  origin: string;
  destination: string;
  rate: number;
};

export type TripDeliveryNote = {
  id: number;
  tripId: number;
  number: string;
  deliveredOn: string | null;
  gasolineQuantity: number;
  dieselQuantity: number;
  totalQuantity: number;
  missingQuantity: number | null;
  product: string;
};

export type TripBillingStatement = {
  id: number;
  number: string;
  status: string;
  month: string;
  startsOn: string;
  endsOn: string;
  issuedOn: string | null;
  dueOn: string | null;
  totalAmount: number;
  totalTva: number;
  grandTotal: number;
};

export type Trip = {
  id: number;
  status: TripStatus;
  cargoDescription: string | null;
  distanceKm: number | null;
  scheduledStartAt: string | null;
  scheduledEndAt: string | null;
  actualStartAt: string | null;
  actualEndAt: string | null;
  truck: Truck;
  driver: TruckDriver | null;
  route: TripRoute;
  deliveryNote: TripDeliveryNote | null;
  billingStatement: TripBillingStatement | null;
};
