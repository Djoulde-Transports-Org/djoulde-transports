import * as yup from 'yup';

export const employeeFormSchema = yup.object({
  firstName: yup.string().required('Le prénom est requis'),
  lastName: yup.string().required('Le nom est requis'),
  role: yup.string().optional(),
  phoneNumber: yup.string().optional(),
  address: yup.string().optional(),
  hireDate: yup.string().optional(),
  status: yup.string().optional(),
  truckId: yup.string().optional(),
});
