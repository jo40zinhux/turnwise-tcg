import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import EmbeddedPostgres from 'embedded-postgres';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const databaseDir = join(root, 'data', 'pg');

const pg = new EmbeddedPostgres({
  databaseDir,
  user: 'turnwise',
  password: 'turnwise',
  port: 5432,
  persistent: true,
  initdbFlags: ['--encoding=UTF8', '--locale=C'],
});

if (!existsSync(databaseDir)) {
  await pg.initialise();
}

await pg.start();

try {
  await pg.createDatabase('turnwise_events');
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  if (!/already exists/i.test(message)) {
    console.warn(message);
  }
}

console.log('Postgres local em localhost:5432 (turnwise_events)');

const stop = async () => {
  await pg.stop();
  process.exit(0);
};

process.on('SIGINT', stop);
process.on('SIGTERM', stop);

await new Promise(() => {});
