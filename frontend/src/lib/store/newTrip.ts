import * as yup from 'yup';

export const newTripSchema = yup.object({
  truckId: yup.string().required('Le camion est requis'),
  routeId: yup.string().required('La route est requise'),
  driverId: yup.string().optional(),
  scheduledStartAt: yup.string().optional(),
  scheduledEndAt: yup.string().optional(),
  deliveryNoteNumber: yup.string().required('Le numéro du bon de livraison est requis'),
  gasolineQuantity: yup.string().optional(),
  dieselQuantity: yup.string().optional(),
});
