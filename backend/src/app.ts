import express from 'express'
import cors from 'cors'
import type { Pool } from 'pg'

export function createApp(pool: Pool) {
  const app = express()

  app.use(cors())
  app.use(express.json())

  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' })
  })

  app.get('/message', async (_req, res) => {
    console.log(
      JSON.stringify({
        event: 'button_click',
        timestamp: new Date().toISOString(),
      }),
    )

    try {
      const result = await pool.query(
        'SELECT content FROM messages ORDER BY id LIMIT 1',
      )

      res.status(200).json({ message: result.rows[0].content })
    } catch (error) {
      console.error('Failed to retrieve message:', error)
      res.status(500).json({ error: 'Failed to retrieve message' })
    }
  })

  return app
}