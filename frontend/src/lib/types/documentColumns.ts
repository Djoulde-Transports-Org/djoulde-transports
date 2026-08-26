export type DocumentColumnCell =
  | 'name'
  | 'number'
  | 'category'
  | 'entity'
  | 'issuedOn'
  | 'uploadDate'
  | 'expiresOn'
  | 'addedBy'
  | 'fileAttached';

export type DocumentColumn = {
  key: string;
  label: string;
  cell: DocumentColumnCell;
};
