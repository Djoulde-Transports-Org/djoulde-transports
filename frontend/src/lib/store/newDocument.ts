import * as yup from 'yup';

export const MAX_DOCUMENT_FILE_SIZE = 10 * 1024 * 1024;

export const ACCEPTED_DOCUMENT_FILE_TYPES = [
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
];

const isProvidedFile = (value: unknown): value is File => value instanceof File && value.size > 0;

export const newDocumentSchema = yup.object({
  title: yup.string().required('Le nom du document est requis'),
  number: yup.string().optional(),
  documentableType: yup.string().required('La catégorie est requise'),
  documentableId: yup.string().required("L'entité liée est requise"),
  docType: yup.string().optional(),
  issuedOn: yup.string().required("La date d'émission est requise"),
  expiresOn: yup
    .string()
    .optional()
    .test(
      'expiryAfterIssue',
      "La date d'expiration doit être postérieure à la date d'émission",
      function expiryAfterIssue(value) {
        if (!value || !this.parent.issuedOn) return true;
        return value >= this.parent.issuedOn;
      }
    ),
  file: yup
    .mixed<File>()
    .required('Le fichier est requis')
    .test('required', 'Le fichier est requis', (value) => isProvidedFile(value))
    .test(
      'fileType',
      'Le fichier doit être un PDF, une image (JPEG, PNG, WebP), un document Word ou un fichier Excel',
      (value) => !isProvidedFile(value) || ACCEPTED_DOCUMENT_FILE_TYPES.includes(value.type)
    )
    .test(
      'fileSize',
      'Le fichier ne doit pas dépasser 10 Mo',
      (value) => !isProvidedFile(value) || value.size <= MAX_DOCUMENT_FILE_SIZE
    ),
});
