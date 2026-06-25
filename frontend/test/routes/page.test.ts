import {render} from '@testing-library/svelte';
import Page from '$routes/+page.svelte';

describe('+page (root)', () => {
  it('renders an h1 element', () => {
    const {container} = render(Page);
    expect(container.querySelector('h1')).toBeInTheDocument();
  });

  it('displays the correct heading text', () => {
    const {getByRole} = render(Page);
    expect(getByRole('heading', {level: 1})).toHaveTextContent('Djoulde Transports frontend');
  });
});
