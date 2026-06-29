import {navItems, roleLabels} from '$lib/store/nav';
import type {Role} from '$lib/types/session';

describe('navItems', () => {
  it('has 7 items', () => {
    expect(navItems).toHaveLength(7);
  });

  it('starts with the dashboard route', () => {
    expect(navItems[0].href).toBe('/dashboard');
  });

  it('every item has a label, href, and icon', () => {
    for (const item of navItems) {
      expect(item.label).toBeTruthy();
      expect(item.href).toBeTruthy();
      expect(item.icon).toBeTruthy();
    }
  });

  it('hrefs are unique', () => {
    const hrefs = navItems.map((i) => i.href);
    expect(new Set(hrefs).size).toBe(hrefs.length);
  });

  it('contains the expected routes', () => {
    const hrefs = navItems.map((i) => i.href);
    expect(hrefs).toContain('/dashboard');
    expect(hrefs).toContain('/flotte');
    expect(hrefs).toContain('/employes');
    expect(hrefs).toContain('/trajets');
    expect(hrefs).toContain('/maintenance');
    expect(hrefs).toContain('/facturation');
    expect(hrefs).toContain('/documents');
  });
});

describe('roleLabels', () => {
  const roles: Role[] = ['super_admin', 'dispatcher', 'billing', 'maintenance', 'driver_readonly'];

  it('has a label for every Role', () => {
    for (const role of roles) {
      expect(roleLabels[role]).toBeTruthy();
    }
  });

  it('returns non-empty strings for all roles', () => {
    for (const role of roles) {
      expect(typeof roleLabels[role]).toBe('string');
      expect(roleLabels[role].length).toBeGreaterThan(0);
    }
  });

  it('maps super_admin to Super Admin', () => {
    expect(roleLabels['super_admin']).toBe('Super Admin');
  });

  it('maps dispatcher to Dispatcher', () => {
    expect(roleLabels['dispatcher']).toBe('Dispatcher');
  });
});
