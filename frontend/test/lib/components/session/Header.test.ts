import {render} from '@testing-library/svelte';
import Header from '$lib/components/session/Header.svelte';

describe('Header', () => {
  it('renders the text prop', () => {
    const {getByText} = render(Header, {text: 'Sign in to your account'});
    expect(getByText('Sign in to your account')).toBeInTheDocument();
  });

  it('has data-testid="welcome-message"', () => {
    const {getByTestId} = render(Header, {text: 'Hello'});
    expect(getByTestId('welcome-message')).toBeInTheDocument();
  });

  it('renders as a span element', () => {
    const {getByTestId} = render(Header, {text: 'Hello'});
    expect(getByTestId('welcome-message').tagName).toBe('SPAN');
  });

  it('text content matches the prop', () => {
    const {getByTestId} = render(Header, {text: 'Custom heading'});
    expect(getByTestId('welcome-message')).toHaveTextContent('Custom heading');
  });

  it('updates when text changes', async () => {
    const {getByTestId, rerender} = render(Header, {text: 'First'});
    expect(getByTestId('welcome-message')).toHaveTextContent('First');

    await rerender({text: 'Second'});
    expect(getByTestId('welcome-message')).toHaveTextContent('Second');
  });
});
