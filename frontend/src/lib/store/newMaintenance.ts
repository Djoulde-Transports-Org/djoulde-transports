import * as yup from 'yup';

export const newMaintenanceSchema = yup.object({
  truckId: yup.string().required('Le camion est requis'),
  kind: yup.string().required('Le type de maintenance est requis'),
  performedById: yup.string().optional(),
  performedOn: yup.string().required('La date de début est requise'),
  estimatedDuration: yup.string().optional(),
  estimatedCost: yup.string().optional(),
});
