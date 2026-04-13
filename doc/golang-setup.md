# Go Development Environment in Pisco Box

## Overview

Pisco Box now includes **Go (Golang)** with automatic installation and configuration during VM provisioning. This enables Go development directly in your Pisco Box environment alongside your PHP applications.

## Environment Configuration

### Automatic Setup

When you provision Pisco Box, the `golang.sh` script automatically:

1. ✅ Installs the latest stable Go version
2. ✅ Configures `GOROOT` at `/usr/local/go`
3. ✅ Configures `GOPATH` at `/go`
4. ✅ Adds Go binaries to system `PATH`
5. ✅ Installs common Go development tools (golangci-lint)

### Environment Variables

After provisioning, the following environment variables are configured:

```bash
export GOROOT=/usr/local/go
export GOPATH=/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
```

These are automatically sourced from `/etc/profile.d/golang.sh` on every shell session.

## Usage

### SSH into Pisco Box

```bash
vagrant ssh
```

### Verify Go Installation

```bash
go version
go env
```

### Create a New Go Project

```bash
# Navigate to GOPATH workspace
cd $GOPATH/src

# Create a new project
mkdir github.com/username/myproject
cd github.com/username/myproject

# Create your Go files
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from Pisco Box!")
}
EOF

# Run the program
go run main.go

# Build the executable
go build -o myapp
./myapp
```

### Go Workspace Structure

```
/go                          ← GOPATH root
├── src/                     ← Source code
│   └── github.com/username/ ← Your projects
├── bin/                     ← Compiled binaries
└── pkg/                     ← Package objects
```

## Development Workflow

### Using Go Modules (Recommended)

Modern Go development uses Go Modules:

```bash
# Create a new project with modules
mkdir ~/mygoapp
cd ~/mygoapp

# Initialize a new module
go mod init github.com/username/mygoapp

# Create main.go and develop
cat > main.go << 'EOF'
package main
import "fmt"
func main() {
    fmt.Println("Hello, Modules!")
}
EOF

# Run your code
go run main.go

# Build release
go build -o myapp

# Manage dependencies
go get github.com/some/package
go mod tidy
```

### Install Go Tools

```bash
# Install golangci-lint (already installed)
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Install other tools as needed
go install github.com/golang/tools/cmd/goimports@latest
```

## Debugging Go Applications

### Using Delve Debugger

Install Delve (Go debugger):

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

Debug your application:

```bash
dlv debug ./main.go
```

## Integration with Pisco Box Services

### Go + PostgreSQL

```go
package main

import (
    "database/sql"
    "fmt"
    _ "github.com/lib/pq"
)

func main() {
    connStr := "user=root password=root dbname=testdb host=localhost port=5432 sslmode=disable"
    db, err := sql.Open("postgres", connStr)
    if err != nil {
        panic(err)
    }
    defer db.Close()
    
    var version string
    err = db.QueryRow("SELECT version();").Scan(&version)
    if err != nil {
        panic(err)
    }
    fmt.Println(version)
}
```

### Go + Redis

```go
package main

import (
    "fmt"
    "github.com/go-redis/redis/v8"
)

func main() {
    client := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
    })
    
    // Use Redis
    ctx := context.Background()
    err := client.Set(ctx, "key", "value", 0).Err()
    if err != nil {
        panic(err)
    }
}
```

### Go + MariaDB

```go
package main

import (
    "database/sql"
    "fmt"
    _ "github.com/go-sql-driver/mysql"
)

func main() {
    db, err := sql.Open("mysql", "root:root@tcp(127.0.0.1:3306)/testdb")
    if err != nil {
        panic(err)
    }
    defer db.Close()
    
    var version string
    err = db.QueryRow("SELECT VERSION();").Scan(&version)
    if err != nil {
        panic(err)
    }
    fmt.Println(version)
}
```

## Common Go Commands

```bash
# Run Go code without building
go run main.go

# Build executable
go build -o myapp

# Test your code
go test ./...

# Format code
go fmt ./...

# Lint code
golangci-lint run ./...

# Get dependencies
go get github.com/user/repo

# Update dependencies
go get -u ./...

# View documentation
go doc fmt

# Run benchmarks
go test -bench=. ./...
```

## File Organization Best Practice

```
project/
├── go.mod                  ← Module definition
├── go.sum                  ← Dependency checksums
├── main.go                 ← Entry point
├── cmd/                    ← Executable packages
│   └── myapp/
│       └── main.go
├── pkg/                    ← Library packages
│   ├── database/
│   ├── api/
│   └── utils/
├── internal/               ← Private packages
├── tests/                  ← Test files
├── docs/                   ← Documentation
└── config/                 ← Configuration files
```

## Troubleshooting

### Go command not found

If `go` is not found, reload your shell profile:

```bash
source /etc/profile
go version
```

### GOPATH not set

Verify environment variables:

```bash
echo $GOPATH
echo $GOROOT
```

Set them manually if needed:

```bash
export GOROOT=/usr/local/go
export GOPATH=/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
```

### Module Issues

Clear module cache if experiencing issues:

```bash
go clean -modcache
go mod download
```

## Resources

- [Official Go Documentation](https://golang.org/doc/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://golang.org/doc/effective_go)
- [Go Module Reference](https://golang.org/ref/mod)
- [Go Tools & Libraries](https://github.com/golang/tools)

## Version Information

- **Go Version**: Latest Stable (installed during provisioning)
- **Installation Path**: `/usr/local/go`
- **GOPATH**: `/go`
- **Package Manager**: go modules (go.mod)

## Next Steps

1. SSH into your Pisco Box environment
2. Verify Go installation: `go version`
3. Create your first Go project in `$GOPATH/src`
4. Explore integration with Pisco Box services (PostgreSQL, Redis, MariaDB)
5. Check out the [Go Community](https://golang.org/help/) for resources and support

---

**Happy Go Coding!** 🚀
