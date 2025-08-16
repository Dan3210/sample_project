import express from 'express';
import cors from 'cors';
import sqlite3 from 'sqlite3';

const app = express();
const db = new sqlite3.Database('./database.sqlite');

app.use(cors());
app.use(express.json());

// Create table if not exists
const initDb = () => {
  db.run('CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)');
};

initDb();

// Get all items
app.get('/api/items', (req, res) => {
  db.all('SELECT * FROM items', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Add item
app.post('/api/items', (req, res) => {
  const { text } = req.body;
  db.run('INSERT INTO items (text) VALUES (?)', [text], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: this.lastID, text });
  });
});

// Delete item
app.delete('/api/items/:id', (req, res) => {
  db.run('DELETE FROM items WHERE id = ?', [req.params.id], function(err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ deleted: this.changes });
  });
});

const PORT = 4000;
app.listen(PORT, () => console.log(`Backend running on port ${PORT}`));
