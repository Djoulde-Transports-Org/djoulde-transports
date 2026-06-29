import {render} from '@testing-library/svelte';
import Icon from '$lib/components/common/Icon.svelte';

describe('Icon', () => {
  it('renders an svg element', () => {
    const {container} = render(Icon, {name: 'dashboard'});
    expect(container.querySelector('svg')).toBeInTheDocument();
  });

  it('applies the size prop as width and height attributes', () => {
    const {container} = render(Icon, {name: 'truck', size: 20});
    const svg = container.querySelector('svg')!;
    expect(svg).toHaveAttribute('width', '20');
    expect(svg).toHaveAttribute('height', '20');
  });

  it('defaults to size 16', () => {
    const {container} = render(Icon, {name: 'users'});
    const svg = container.querySelector('svg')!;
    expect(svg).toHaveAttribute('width', '16');
    expect(svg).toHaveAttribute('height', '16');
  });

  it('forwards the class prop to the svg', () => {
    const {container} = render(Icon, {name: 'wrench', class: 'shrink-0 text-accent'});
    expect(container.querySelector('svg')).toHaveClass('shrink-0', 'text-accent');
  });

  it('renders a different icon for each name', () => {
    const {container: c1} = render(Icon, {name: 'dashboard'});
    const {container: c2} = render(Icon, {name: 'truck'});
    const path1 = c1.querySelector('svg')?.innerHTML;
    const path2 = c2.querySelector('svg')?.innerHTML;
    expect(path1).not.toEqual(path2);
  });

  it('renders every registered icon name without throwing', () => {
    const names = [
      'dashboard', 'truck', 'users', 'navigation', 'wrench', 'receipt', 'folder',
      'chevron-right', 'chevron-left', 'chevron-down', 'chevron-up',
      'plus', 'x', 'check', 'alert-triangle', 'info', 'search', 'filter',
      'download', 'upload', 'edit', 'trash', 'eye', 'eye-off', 'refresh',
      'clock', 'calendar', 'map-pin', 'phone', 'mail', 'user', 'settings', 'logout',
    ] as const;
    for (const name of names) {
      const {container} = render(Icon, {name});
      expect(container.querySelector('svg')).toBeInTheDocument();
    }
  });
});
