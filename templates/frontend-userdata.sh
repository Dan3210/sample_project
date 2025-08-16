#!/bin/bash
set -e

# Update system
yum update -y

# Install Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install nginx
yum install -y nginx

# Install build tools
yum groupinstall -y "Development Tools"
yum install -y python3

# Create application directory
mkdir -p /opt/${project_name}/frontend
cd /opt/${project_name}/frontend

# Create package.json
cat > package.json << 'EOF'
{
  "name": "frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "scripts": {
    "build": "npx webpack --mode production",
    "start": "npx serve -s build"
  },
  "devDependencies": {
    "@babel/core": "^7.22.0",
    "@babel/preset-env": "^7.22.0",
    "@babel/preset-react": "^7.22.0",
    "babel-loader": "^9.1.0",
    "css-loader": "^6.8.0",
    "html-webpack-plugin": "^5.5.0",
    "style-loader": "^3.3.0",
    "webpack": "^5.88.0",
    "webpack-cli": "^5.1.0"
  }
}
EOF

# Create webpack.config.js
cat > webpack.config.js << 'EOF'
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'build'),
    filename: 'bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react'],
          },
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
  ],
  resolve: {
    extensions: ['.js', '.jsx'],
  },
};
EOF

# Create public directory and index.html
mkdir -p public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Todo List</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create src directory and React components
mkdir -p src

# Create index.js
cat > src/index.js << 'EOF'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const root = createRoot(document.getElementById('root'));
root.render(<App />);
EOF

# Create App.js with backend URL from Terraform
cat > src/App.js << 'EOF'
import React, { useEffect, useState } from 'react';

function App() {
  const [items, setItems] = useState([]);
  const [text, setText] = useState('');

  useEffect(() => {
    fetch('${backend_url}/api/items')
      .then(res => res.json())
      .then(setItems);
  }, []);

  const addItem = async (e) => {
    e.preventDefault();
    const res = await fetch('${backend_url}/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text })
    });
    const item = await res.json();
    setItems([...items, item]);
    setText('');
  };

  const deleteItem = async (id) => {
    await fetch(`${backend_url}/api/items/${id}`, { method: 'DELETE' });
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
EOF

# Install dependencies
npm install

# Build the application
npm run build

# Configure nginx
cat > /etc/nginx/conf.d/${project_name}.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /opt/${project_name}/frontend/build;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass ${backend_url};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Remove default nginx config
rm -f /etc/nginx/conf.d/default.conf

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

echo "Frontend deployment completed successfully!"
