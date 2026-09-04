import test from 'node:test'
import assert from 'node:assert/strict'
import { createApp } from '../dist/app.js'

test('API health and message endpoints work', async () => {
  const fakePool = {
    query: async () => ({
      rows: [{ content: 'Hello from PostgreSQL!' }],
    }),
  }

  const app = createApp(fakePool)
  const server = app.listen(0)

  await new Promise((resolve) => {
    server.once('listening', resolve)
  })

  const address = server.address()

  assert.ok(address)
  assert.equal(typeof address, 'object')

  try {
    const healthResponse = await fetch(
      `http://127.0.0.1:${address.port}/health`,
    )

    assert.equal(healthResponse.status, 200)
    assert.deepEqual(await healthResponse.json(), {
      status: 'ok',
    })

    const messageResponse = await fetch(
      `http://127.0.0.1:${address.port}/message`,
    )

    assert.equal(messageResponse.status, 200)
    assert.deepEqual(await messageResponse.json(), {
      message: 'Hello from PostgreSQL!',
    })
  } finally {
    server.close()
  }
})