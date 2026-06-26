export type Session = {
  access_token: string;
  token_type: string;
  expires_in: number;
  created_at: number;
  user_id: number;
  roles: Role[];
};

export type Role =
  | 'super_admin'
  | 'dispatcher'
  | 'billing'
  | 'maintenance'
  | 'driver_readonly';
