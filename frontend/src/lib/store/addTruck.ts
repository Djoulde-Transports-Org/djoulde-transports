import * as yup from 'yup';

export const addTruckSchema = yup.object({
  plateNumber: yup.string().required("L'immatriculation est requise"),
  vin: yup.string().optional(),
  make: yup.string().optional(),
  model: yup.string().required('Le modèle est requis'),
  year: yup
    .string()
    .required("L'année est requise")
    .matches(/^\d{4}$/, {message: 'Année invalide', excludeEmptyString: true})
    .test('year-range', 'Année invalide', (value) => {
      if (!value) return true;
      const year = Number(value);
      const currentYear = new Date().getFullYear();
      return year > 1900 && year <= currentYear + 1;
    }),
  status: yup.string().optional(),
  tankPlateNumber: yup.string().required("L'immatriculation de la citerne est requise"),
  tankCapacity: yup
    .string()
    .required('La capacité est requise')
    .matches(/^\d+$/, {message: 'Capacité invalide', excludeEmptyString: true}),
  tankMake: yup.string().optional(),
  tankModel: yup.string().optional(),
  tankVin: yup.string().optional(),
  tankYear: yup.string().optional(),
  driverId: yup.string().optional(),
  lastOilChangeOn: yup.string().optional(),
  truckInsuranceExpiresOn: yup.string().optional(),
  cargoInsuranceExpiresOn: yup.string().optional(),
  technicalInspectionExpiresOn: yup.string().optional(),
  operatingPermitExpiresOn: yup.string().optional(),
  truckRegistrationExpiresOn: yup.string().optional(),
});
