import express from 'express';
import cors from 'cors';
import sqlite3 from 'sqlite3';

const app = express();

app.use(cors());
app.use(express.json());

// Use different database path for Docker vs local
const dbPath = process.env.NODE_ENV === 'production' 
  ? '/app/data/database.sqlite' 
  : './database.sqlite';

console.log('Using database path:', dbPath);

// Initialize database with error handling
let db;
try {
  db = new sqlite3.Database(dbPath);
  db.run('CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)');
  console.log('Database initialized successfully');
} catch (error) {
  console.error('Database initialization error:', error);
}

// Get all items
app.get('/api/items', (req, res) => {
  if (!db) {
    return res.status(500).json({ error: 'Database not available' });
  }
  
  db.all('SELECT * FROM items', [], (err, rows) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: err.message });
    }
    res.json(rows || []);
  });
});

// Add item
app.post('/api/items', (req, res) => {
  if (!db) {
    return res.status(500).json({ error: 'Database not available' });
  }
  
  const { text } = req.body;
  if (!text) return res.status(400).json({ error: 'Text is required' });
  
  db.run('INSERT INTO items (text) VALUES (?)', [text], function(err) {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: err.message });
    }
    res.json({ id: this.lastID, text });
  });
});

// Delete item
app.delete('/api/items/:id', (req, res) => {
  if (!db) {
    return res.status(500).json({ error: 'Database not available' });
  }
  
  db.run('DELETE FROM items WHERE id = ?', [req.params.id], function(err) {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: err.message });
    }
    res.json({ deleted: this.changes });
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  if (db) {
    db.close();
  }
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  if (db) {
    db.close();
  }
  process.exit(0);
});
