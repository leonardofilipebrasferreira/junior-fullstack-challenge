// @vitest-environment jsdom

import { afterEach, expect, test, vi } from 'vitest'
import { cleanup, fireEvent, render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/vitest'
import App from './App'

afterEach(() => {
  cleanup()
  vi.unstubAllGlobals()
})

test('shows the message returned by the API', async () => {
  const fetchMock = vi.fn().mockResolvedValue({
    ok: true,
    json: async () => ({
      message: 'Hello from PostgreSQL!',
    }),
  })

  vi.stubGlobal('fetch', fetchMock)

  render(<App />)

  fireEvent.click(
    screen.getByRole('button', {
      name: 'Obter mensagem',
    }),
  )

  expect(
    await screen.findByText('Hello from PostgreSQL!'),
  ).toBeInTheDocument()

  expect(fetchMock).toHaveBeenCalledWith('/api/message')
})