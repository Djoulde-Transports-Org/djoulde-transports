import type {DocType} from '$lib/types/document';

export const docTypeLabels: Record<DocType, string> = {
  other: 'Autre',
  truck_insurance: 'Assurance camion',
  product_insurance: 'Assurance produit',
  driver_license: 'Permis de conduire',
  driver_insurance: 'Assurance chauffeur',
  technical_inspection: 'Visite technique',
  loading_certificate: 'Certificat de chargement',
  conformity_certificate: 'Certificat de conformité',
  transport_card: 'Carte de transport',
  truck_registration: 'Carte grise',
  invoice: 'Facture',
  delivery_note: 'Bon de livraison',
  maintenance_note: 'Fiche de maintenance',
};

export const docTypeLabel = (docType: DocType): string => docTypeLabels[docType] ?? docType;
