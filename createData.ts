import { writeFile, mkdir } from 'fs/promises'
import path from 'path'
import asyncPool from 'tiny-async-pool'
const folders = 100
const amount = folders * 50000
const timeStart = Date.now()
;(async () => {
  await mkdir('node_modules/uploads')
    .catch((e) => {})
    .then(async (err) => {
      for await (const amountDone of asyncPool(100, [...Array(amount).keys()], async (i) => {
        const folder = String(i % folders)
        const localPath = path.join('node_modules/uploads', folder)
        await mkdir(localPath).catch((e) => {})
        await writeFile(localPath + '/' + String(i), String(Math.random()))
        return i
      })) {
        if (amountDone % 10000 === 0) {
        console.log(`${(Date.now() - timeStart) / 1000} seconds, ${(amountDone / amount) * 100}% written to disk & ${amountDone} files`)
        }
      }
    })
})()
