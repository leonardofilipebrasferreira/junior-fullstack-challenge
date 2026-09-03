import { useState } from 'react'

function App() {
  const [message, setMessage] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleGetMessage() {
    setIsLoading(true)
    setError('')

    try {
      const response = await fetch('http://localhost:3000/message')

      if (!response.ok) {
        throw new Error('Failed to fetch message')
      }

      const data: { message: string } = await response.json()
      setMessage(data.message)
    } catch {
      setError('Não foi possível obter a mensagem.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <main>
      <h1>Full Stack Challenge</h1>
      <p>AWS & DevOps</p>

      <button
        type="button"
        onClick={handleGetMessage}
        disabled={isLoading}
      >
        {isLoading ? 'A carregar...' : 'Obter mensagem'}
      </button>

      {message && <p>{message}</p>}
      {error && <p>{error}</p>}
    </main>
  )
}

export default App