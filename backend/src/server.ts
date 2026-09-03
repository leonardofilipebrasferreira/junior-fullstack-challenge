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

app.get('/db-test', async (_req, res) => {
  const result = await pool.query('SELECT NOW()')

  res.status(200).json({
    databaseTime: result.rows[0].now
  })
})

app.listen(PORT, () => {
  console.log(`API running on http://localhost:${PORT}`)
})