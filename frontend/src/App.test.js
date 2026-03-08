import { render, screen } from '@testing-library/react';
import App from './App';

test('renders login page when user is not authenticated', () => {
  localStorage.removeItem('token');
  render(<App />);

  expect(screen.getByRole('heading', { name: /login/i })).toBeInTheDocument();
  expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
  expect(screen.getByRole('link', { name: /register/i })).toBeInTheDocument();
});
