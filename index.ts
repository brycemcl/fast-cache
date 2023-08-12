import express from 'express'
import multer from 'multer'

const upload = multer({ storage: multer.memoryStorage() })
const app = express()
let buf = Buffer.from('Hey!')
app.post('/', upload.single('file'), function (req, res, next) {
  if (req?.file) {
    buf = req.file.buffer
  }
  res.send('received')
})
app.get('/', function (req, res, next) {
  res.send(buf)
})
app.listen(3000, () => console.log('Server ready'))
