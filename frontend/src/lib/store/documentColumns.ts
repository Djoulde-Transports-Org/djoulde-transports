import type {DocumentColumn} from '$lib/types/documentColumns';

export const documentColumns: DocumentColumn[] = [
  {key: 'title', label: 'Nom', cell: 'name'},
  {key: 'number', label: 'N°', cell: 'number'},
  {key: 'docType', label: 'Catégorie', cell: 'category'},
  {key: 'documentableId', label: 'Lié à', cell: 'entity'},
  {key: 'issuedOn', label: 'Émis le', cell: 'issuedOn'},
  {key: 'createdAt', label: 'Ajouté le', cell: 'uploadDate'},
  {key: 'expiresOn', label: 'Expire le', cell: 'expiresOn'},
  {key: 'uploadedBy', label: 'Ajouté par', cell: 'addedBy'},
  {key: 'fileAttached', label: 'Fichier joint', cell: 'fileAttached'},
];
