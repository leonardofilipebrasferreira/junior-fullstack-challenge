import { createDatabasePool, initializeDatabase } from './db.js'
import { createApp } from './app.js'

const PORT = 3000

async function startServer() {
  const pool = await createDatabasePool()

  await initializeDatabase(pool)

  const app = createApp(pool)

  app.listen(PORT, () => {
    console.log(`API running on http://localhost:${PORT}`)
  })
}

startServer().catch((error) => {
  console.error('Failed to start API:', error)
  process.exit(1)
})