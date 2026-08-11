import type {Truck, TruckDriver} from './truck';
import type {Route} from './route';
import type {BillingStatement} from './billing';

export type TripStatus = 'scheduled' | 'in_progress' | 'completed' | 'cancelled';

export type TripRoute = Route;

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
  billingStatement: BillingStatement | null;
  pretaxAmount: number | null;
};

export type CreateTripPayload = {
  truckId: number;
  routeId: number;
  driverId?: number;
  scheduledStartAt?: string;
  scheduledEndAt?: string;
  deliveryNote: {
    number: string;
    gasolineQuantity?: number;
    dieselQuantity?: number;
  };
};

export type NewTripValues = {
  truckId: string;
  routeId: string;
  driverId: string;
  scheduledStartAt: string;
  scheduledEndAt: string;
  deliveryNoteNumber: string;
  gasolineQuantity: string;
  dieselQuantity: string;
};
