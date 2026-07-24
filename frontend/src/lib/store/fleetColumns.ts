import type {FleetColumn} from '$lib/types/fleetColumns';

export const fleetColumns: FleetColumn[] = [
  {key: 'plateNumber', label: 'Immatriculation', cell: 'plate'},
  {key: 'model', label: 'Modèle', cell: 'model'},
  {key: 'tank', label: 'Citerne', cell: 'citerne'},
  {key: 'status', label: 'Statut', cell: 'status'},
  {key: 'lastOilChangeOn', label: 'Dernière vidange', cell: 'oilChange'},
  {key: 'truckInsuranceDaysRemaining', label: 'Ass. camion', cell: 'truckInsurance'},
  {key: 'cargoInsuranceDaysRemaining', label: 'Ass. produit', cell: 'cargoInsurance'},
  {
    key: 'technicalInspectionDaysRemaining',
    label: 'Visite tech.',
    cell: 'technicalInspection',
  },
  {key: 'operatingPermitDaysRemaining', label: 'Carte de Transport', cell: 'operatingPermit'},
  {
    key: 'truckRegistrationDaysRemaining',
    label: 'Carte grise',
    cell: 'truckRegistration',
  },
  {key: 'conformityCertificate', label: 'Baremage', cell: 'conformityCertificate'},
];
