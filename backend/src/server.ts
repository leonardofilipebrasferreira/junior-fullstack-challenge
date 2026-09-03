import { pool } from './db.js'
import express from 'express'
import cors from 'cors'

const app = express()
const PORT = 3000

app.use(cors())
app.use(express.json())

app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok'
  })
})
app.get('/message', async (_req, res) => {
  console.log(JSON.stringify({
    event: 'button_click',
    timestamp: new Date().toISOString()
  }))

  const result = await pool.query(
    'SELECT content FROM messages ORDER BY id LIMIT 1'
  )

  res.status(200).json({
    message: result.rows[0].content
  })
})

app.listen(PORT, () => {
  console.log(`API running on http://localhost:${PORT}`)
})