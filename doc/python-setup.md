# Python Development Environment in Pisco Box

## Overview

Pisco Box now includes **dual Python support** with automatic installation and configuration:
- **Python 3** (default, latest stable)
- **Python 2.7** (legacy compatibility)

Both versions include `pip` package managers and are automatically configured during VM provisioning.

## Environment Configuration

### Automatic Setup

When you provision Pisco Box, the `python.sh` script automatically:

1. ✅ Installs Python 3 (latest stable)
2. ✅ Installs Python 2.7 (legacy)
3. ✅ Configures pip for both versions
4. ✅ Creates convenient command aliases
5. ✅ Sets up environment variables

### Environment Variables

After provisioning, the following environment variable is configured:

```bash
export PYTHONPATH=/usr/local/lib/python3/site-packages:/usr/lib/python3/site-packages
```

This is automatically sourced from `/etc/profile.d/python.sh` on every shell session.

## Python Version Aliases

Clear, easy-to-remember aliases for accessing different Python versions:

| Command | Python Version |
|---------|----------------|
| `python3` | Python 3 (default) |
| `python30` | Python 3 (latest) |
| `python3X` | Python 3.X (e.g., `python311` for 3.11) |
| `python2` | Python 2.7 |
| `python27` | Python 2.7 specific |
| `python20` | Python 2.0 |

### pip Aliases

| Command | pip Version |
|---------|-------------|
| `pip3` | pip for Python 3 |
| `pip30` | pip3 (main) |
| `pip3X` | pip for Python 3.X |
| `pip2` | pip for Python 2.7 |
| `pip27` | pip2 specific |
| `pip20` | pip2 (legacy) |

## Usage

### SSH into Pisco Box

```bash
vagrant ssh
```

### Verify Python Installation

```bash
# Check Python 3
python3 --version
python30 --version

# Check Python 2.7 (if installed)
python2 --version
python27 --version

# View environment variables
python3 -m site
```

### Create a Python 3 Project

```bash
# Create project directory
mkdir -p ~/projects/myapp
cd ~/projects/myapp

# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate

# Create your Python file
cat > main.py << 'EOF'
def hello():
    print("Hello from Pisco Box!")

if __name__ == "__main__":
    hello()
EOF

# Run the program
python3 main.py

# Or using alias
python30 main.py
```

### Create a Python 2.7 Project (Legacy)

```bash
# Create project directory
mkdir -p ~/projects/legacy_app
cd ~/projects/legacy_app

# Create your Python 2 file
cat > main.py << 'EOF'
# -*- coding: utf-8 -*-
def hello():
    print "Hello from Python 2.7!"

if __name__ == "__main__":
    hello()
EOF

# Run the program
python2 main.py

# Or using alias
python27 main.py
```

## Package Management

### Install Packages with pip3

```bash
# Install a package for Python 3
pip3 install requests
pip30 install flask

# Install multiple packages
pip3 install django numpy pandas

# Install from requirements file
pip3 install -r requirements.txt

# Upgrade a package
pip3 install --upgrade requests
```

### Install Packages with pip2 (Legacy)

```bash
# Install a package for Python 2.7
pip2 install requests
pip27 install flask

# Check installed packages
pip2 list

# Uninstall a package
pip2 uninstall requests
```

### Common Packages

| Package | Purpose | Python 3 | Python 2.7 |
|---------|---------|----------|-----------|
| `requests` | HTTP library | ✅ | ✅ |
| `flask` | Web framework | ✅ | ✅ |
| `django` | Web framework | ✅ | ⚠️ Limited |
| `numpy` | Numerical computing | ✅ | ✅ |
| `pandas` | Data analysis | ✅ | ⚠️ Limited |
| `pytest` | Testing | ✅ | ✅ |
| `sqlalchemy` | ORM | ✅ | ✅ |

## Virtual Environments

### Create Virtual Environment (Python 3)

Virtual environments isolate project dependencies:

```bash
# Navigate to project directory
cd ~/my_project

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Your prompt should show (venv)
# Install packages in isolation
pip install -r requirements.txt

# Deactivate when done
deactivate
```

### Using virtualenv (Alternative)

```bash
# Install virtualenv
pip3 install virtualenv

# Create virtual environment
virtualenv my_env

# Activate
source my_env/bin/activate

# Install dependencies
pip install flask requests

# Deactivate
deactivate
```

## Development Workflow

### Project Structure

```
my_project/
├── venv/                       ← Virtual environment (ignored)
├── README.md                   ← Project documentation
├── requirements.txt            ← Python dependencies
├── main.py                     ← Entry point
├── src/                        ← Source code
│   ├── __init__.py
│   ├── app.py
│   └── utils.py
├── tests/                      ← Test files
│   ├── __init__.py
│   ├── test_app.py
│   └── test_utils.py
├── .gitignore                  ← Git ignore file
└── setup.py                    ← Package setup (optional)
```

### Creating requirements.txt

```bash
# Generate from installed packages
pip freeze > requirements.txt

# Or manually create
cat > requirements.txt << 'EOF'
flask==2.3.0
requests==2.28.0
sqlalchemy==2.0.0
pytest==7.2.0
EOF

# Install from requirements
pip install -r requirements.txt
```

## Debugging Python Applications

### Using pdb (Python Debugger)

```python
# Add breakpoint to your code
def my_function():
    x = 10
    breakpoint()  # Python 3.7+
    return x * 2
```

Run with debugger:
```bash
python3 -m pdb main.py
```

### Using Python 3.7+ Breakpoint

```python
def calculate():
    result = 0
    breakpoint()  # Debugger starts here
    return result

if __name__ == "__main__":
    calculate()
```

## Integration with Pisco Box Services

### Python + PostgreSQL

```python
import psycopg2

try:
    conn = psycopg2.connect(
        host="localhost",
        database="testdb",
        user="root",
        password="root"
    )
    
    cur = conn.cursor()
    cur.execute("SELECT version();")
    version = cur.fetchone()
    print(f"PostgreSQL version: {version}")
    
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
```

Install driver:
```bash
pip3 install psycopg2-binary
```

### Python + MySQL/MariaDB

```python
import mysql.connector

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="root",
        database="testdb"
    )
    
    cursor = conn.cursor()
    cursor.execute("SELECT VERSION();")
    version = cursor.fetchone()
    print(f"MySQL version: {version}")
    
    cursor.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
```

Install driver:
```bash
pip3 install mysql-connector-python
```

### Python + Redis

```python
import redis

try:
    r = redis.Redis(
        host='localhost',
        port=6379,
        decode_responses=True
    )
    
    # Set a value
    r.set('key', 'value')
    
    # Get a value
    value = r.get('key')
    print(f"Redis value: {value}")
except Exception as e:
    print(f"Error: {e}")
```

Install driver:
```bash
pip3 install redis
```

### Python + SQLite

```python
import sqlite3

try:
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    
    # Create table
    cursor.execute('''CREATE TABLE users
                      (id INTEGER PRIMARY KEY, name TEXT)''')
    
    # Insert data
    cursor.execute("INSERT INTO users (name) VALUES (?)", ("John",))
    conn.commit()
    
    # Query data
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    print(users)
    
    conn.close()
except Exception as e:
    print(f"Error: {e}")
```

## Web Development with Flask

### Simple Flask Application

```python
# app.py
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify(message="Hello from Pisco Box!")

@app.route('/api/status')
def status():
    return jsonify(status="ok", environment="pisco_box")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

Install and run:
```bash
pip3 install flask
python3 app.py
```

Access at: `http://192.168.56.110:5000`

## Testing Python Code

### Unit Testing with pytest

```python
# test_main.py
def add(a, b):
    return a + b

def test_add():
    assert add(2, 3) == 5
    assert add(0, 0) == 0
    assert add(-1, 1) == 0

def test_add_strings():
    assert add("Hello", " World") == "Hello World"
```

Run tests:
```bash
# Install pytest
pip3 install pytest

# Run tests
pytest test_main.py

# Run with verbose output
pytest -v test_main.py

# Run specific test
pytest test_main.py::test_add
```

## Common Commands Reference

```bash
# Check Python version
python3 --version
python2 --version

# Run Python script
python3 script.py
python2 script.py

# Interactive Python shell (REPL)
python3
python2

# Check pip version
pip3 --version
pip2 --version

# List installed packages
pip3 list
pip2 list

# Search for packages
pip search requests

# Install specific version
pip3 install requests==2.28.0

# Upgrade pip
pip3 install --upgrade pip

# Create virtual environment
python3 -m venv myenv

# Run module as script
python3 -m json.tool

# Get module documentation
python3 -m pydoc json

# Execute code from command line
python3 -c "print('Hello')"

# Check which Python executable
which python3
which python2
```

## Troubleshooting

### Python command not found

```bash
# Reload shell profile
source /etc/profile

# Check if Python is installed
which python3
which python2

# Verify installation
python3 --version
```

### pip Install Fails

```bash
# Upgrade pip
python3 -m pip install --upgrade pip

# Install with no cache
pip3 install --no-cache-dir package_name

# Install from specific URL
pip3 install git+https://github.com/user/repo.git

# Check pip configuration
pip3 config list
```

### Virtual Environment Issues

```bash
# Remove corrupted venv
rm -rf venv

# Recreate virtual environment
python3 -m venv venv
source venv/bin/activate

# Update package tools in venv
pip install --upgrade pip setuptools wheel
```

### ModuleNotFoundError

```bash
# Check if module is installed
pip3 list

# Install missing module
pip3 install module_name

# Check Python path
python3 -c "import sys; print(sys.path)"
```

## Best Practices

1. **Always use virtual environments** for projects to isolate dependencies
2. **Use Python 3 by default** - Only use Python 2.7 for legacy code
3. **Maintain requirements.txt** to document project dependencies
4. **Use meaningful variable and function names**
5. **Add docstrings** to functions and classes
6. **Use type hints** (Python 3.5+)
7. **Follow PEP 8** style guide
8. **Write tests** for your code
9. **Use version control** (.gitignore your venv directory)
10. **Document your project** with README and comments

## Resources

- [Official Python Documentation](https://docs.python.org/3/)
- [Python 2.7 Documentation](https://docs.python.org/2.7/) (Legacy)
- [PEP 8 - Style Guide](https://www.python.org/dev/peps/pep-0008/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Django Documentation](https://docs.djangoproject.com/)
- [pip Documentation](https://pip.pypa.io/)
- [virtualenv Documentation](https://virtualenv.pypa.io/)

## Version Information

- **Python 3**: Latest stable (installed during provisioning)
- **Python 2.7**: For legacy compatibility
- **pip3**: Latest version
- **pip2**: Latest version (if Python 2.7 available)
- **Package Manager**: pip

## Next Steps

1. SSH into your Pisco Box environment: `vagrant ssh`
2. Verify Python installation: `python3 --version`
3. Create your first Python project
4. Set up a virtual environment
5. Install your required packages
6. Start building amazing Python applications!

---

**Happy Python Coding!** 🐍

