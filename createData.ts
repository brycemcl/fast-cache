import { writeFile, mkdir } from 'fs/promises'
import path from 'path'
import { randomUUID } from 'crypto'
;(async () => {
  const timeStart = Date.now()
  await mkdir('node_modules/uploads')
    .catch((e) => {})
    .then(async (err) => {
      const folders = 100
      const amount = folders * 5000
      for (let i = 0; i <= amount; i++) {
        const folder = String(i % (folders))
        const localPath = path.join('node_modules/uploads', folder)
        await mkdir(localPath).catch((e) => {})
        await writeFile(localPath + '/' + String(i), randomUUID())
        if (i % 10000 === 0) {
          console.log(`${(Date.now() - timeStart) / 1000} seconds, ${(i / amount) * 100}% done & ${i} files`)
        }
      }
    })
})()
