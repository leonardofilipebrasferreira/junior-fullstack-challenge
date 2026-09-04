import 'dotenv/config'
import { GetSecretValueCommand, SecretsManagerClient } from '@aws-sdk/client-secrets-manager'
import { Pool } from 'pg'

type DatabaseCredentials = {
  username: string
  password: string
}

async function getDatabaseCredentials(): Promise<DatabaseCredentials> {
  const secretArn = process.env.DB_SECRET_ARN

  if (!secretArn) {
    if (!process.env.DB_USER || !process.env.DB_PASSWORD) {
      throw new Error('Database credentials are not configured')
    }

    return {
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    }
  }

  const client = new SecretsManagerClient({})

  const response = await client.send(
    new GetSecretValueCommand({
      SecretId: secretArn,
    }),
  )

  if (!response.SecretString) {
    throw new Error('Database secret does not contain a SecretString')
  }

  const secret = JSON.parse(response.SecretString) as {
    username: string
    password: string
  }

  return {
    username: secret.username,
    password: secret.password,
  }
}

export async function createDatabasePool(): Promise<Pool> {
  const credentials = await getDatabaseCredentials()

  return new Pool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT ?? 5432),
    user: credentials.username,
    password: credentials.password,
    database: process.env.DB_NAME,
    ssl:
      process.env.DB_SSL === 'true'
        ? {
            rejectUnauthorized: false,
          }
        : false,
  })
}

export async function initializeDatabase(pool: Pool): Promise<void> {
  const client = await pool.connect()

  try {
    await client.query('BEGIN')

    // Prevent multiple API replicas from initializing the schema simultaneously
    await client.query('SELECT pg_advisory_xact_lock(42, 1)')

    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        content TEXT NOT NULL
      )
    `)

    await client.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS messages_content_unique
      ON messages (content)
    `)

    await client.query(`
      INSERT INTO messages (content)
      VALUES ('Hello from PostgreSQL!')
      ON CONFLICT (content) DO NOTHING
    `)

    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
}