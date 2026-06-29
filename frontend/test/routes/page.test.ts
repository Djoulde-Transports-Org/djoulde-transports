import {render} from '@testing-library/svelte';
import Page from '$routes/(app)/dashboard/+page.svelte';

describe('+page (dashboard)', () => {
  it('renders an h1 element', () => {
    const {container} = render(Page);
    expect(container.querySelector('h1')).toBeInTheDocument();
  });

  it('displays the dashboard heading', () => {
    const {getByRole} = render(Page);
    expect(getByRole('heading', {level: 1})).toHaveTextContent('Tableau de bord');
  });
});
