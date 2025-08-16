import React, { useEffect, useState } from 'react';

function App() {
  const [items, setItems] = useState([]);
  const [text, setText] = useState('');

  useEffect(() => {
    fetch('/api/items')
      .then(res => res.json())
      .then(setItems);
  }, []);

  const addItem = async (e) => {
    e.preventDefault();
    const res = await fetch('/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text })
    });
    const item = await res.json();
    setItems([...items, item]);
    setText('');
  };

  const deleteItem = async (id) => {
    await fetch(`/api/items/${id}`, { method: 'DELETE' });
    setItems(items.filter(i => i.id !== id));
  };

  return (
    <div style={{ maxWidth: 400, margin: '2rem auto', fontFamily: 'sans-serif' }}>
      <h2>Todo List</h2>
      <form onSubmit={addItem}>
        <input value={text} onChange={e => setText(e.target.value)} required />
        <button type="submit">Add</button>
      </form>
      <ul>
        {items.map(item => (
          <li key={item.id}>
            {item.text} <button onClick={() => deleteItem(item.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
