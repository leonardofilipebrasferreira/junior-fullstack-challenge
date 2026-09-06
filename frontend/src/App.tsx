import { useState } from 'react'
import './App.css'

function App() {
  const [message, setMessage] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleGetMessage() {
    setIsLoading(true)
    setError('')
    setMessage('')

    try {
      const response = await fetch('/api/message')

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
    <div className="app-shell">
      <main className="app-card">
        <header className="app-header">
          <span className="eyebrow">AWS &amp; DevOps</span>

          <h1>Full Stack Challenge</h1>

          <p className="subtitle">
            Aplicação Full Stack com React, Node.js e PostgreSQL, preparada para
            deployment em Kubernetes na AWS.
          </p>
        </header>

        <div className="stack-flow" aria-label="Application architecture">
          <span>React</span>
          <span className="stack-arrow" aria-hidden="true">
            →
          </span>
          <span>Node.js</span>
          <span className="stack-arrow" aria-hidden="true">
            →
          </span>
          <span>PostgreSQL</span>
        </div>

        <section className="message-panel">
          <div className="panel-header">
            <div>
              <span className="panel-kicker">DATABASE MESSAGE</span>
              <h2>Mensagem do PostgreSQL</h2>
            </div>

            <span className="service-badge">API + PostgreSQL</span>
          </div>

          <div
            className={`message-box ${
              error ? 'message-box message-box--error' : 'message-box'
            }`}
          >
            {isLoading ? (
              <div className="loading-state">
                <span className="spinner" aria-hidden="true" />
                <span>A obter mensagem...</span>
              </div>
            ) : error ? (
              <p role="alert">{error}</p>
            ) : message ? (
              <p className="database-message">{message}</p>
            ) : (
              <p className="message-placeholder">
                A mensagem guardada na base de dados será apresentada aqui.
              </p>
            )}
          </div>

          <button
            type="button"
            className="primary-button"
            onClick={handleGetMessage}
            disabled={isLoading}
            aria-busy={isLoading}
          >
            <span>{isLoading ? 'A carregar...' : 'Obter mensagem'}</span>
            <span className="button-arrow" aria-hidden="true">
              →
            </span>
          </button>
        </section>

        <footer className="app-footer">
          <span>React</span>
          <span>Node.js</span>
          <span>PostgreSQL</span>
          <span>AWS</span>
          <span>Kubernetes</span>
        </footer>
      </main>
    </div>
  )
}

export default App