// Maintenance kinds are backed by a database table so new ones can be added
// on the fly. These are just friendlier French labels for the four built-in
// kinds seeded at launch — anything else displays under its own stored name.
export const maintenanceKindLabels: Record<string, string> = {
  routine: 'Entretien courant',
  repair: 'Réparation',
  inspection: 'Inspection',
  oil_change: 'Vidange',
};

export const maintenanceKindLabel = (name: string): string => maintenanceKindLabels[name] ?? name;
