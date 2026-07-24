export type Session = {
  accessToken: string;
  tokenType: string;
  expiresIn: number;
  createdAt: number;
  userId: number;
  roles: Role[];
};

export type Role = 'super_admin' | 'dispatcher' | 'billing' | 'maintenance' | 'driver_readonly';
