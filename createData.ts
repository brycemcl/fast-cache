import { writeFile, mkdir } from 'fs/promises'
import path from 'path'
const prom:Promise<any>[] = []
;(async () => {
  const timeStart = Date.now()
  await mkdir('node_modules/uploads')
    .catch((e) => {})
    .then(async (err) => {
      const folders = 100
      const amount = folders * 25000
      for (let i = 0; i <= amount; i++) {
        const folder = String(i % (folders))
        const localPath = path.join('node_modules/uploads', folder)
        await mkdir(localPath).catch((e) => {})
        prom.push(writeFile(localPath + '/' + String(i), String(Math.random())))
        if (i % 10000 === 0) {
          console.log(`${(Date.now() - timeStart) / 1000} seconds, ${(i / amount) * 100}% started & ${i} files`)
        }
      }
    })
  await Promise.all(prom)
})()
