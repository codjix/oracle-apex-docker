# Oracle APEX Docker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An all-in-one Docker image for Oracle APEX development. This container bundles Oracle Database XE 21c, Oracle REST Data Services (ORDS), and Oracle APEX into a single, easy-to-deploy image based on Oracle Linux.

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Image Types](#-image-types)
- [Building the Image](#-building-the-image)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Accessing APEX](#-accessing-apex)
- [Default Credentials](#-default-credentials)
- [Data Persistence](#-data-persistence)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

## ✨ Features

- **All-in-One Solution**: Oracle Database XE 21c, ORDS, and APEX in a single container
- **Two Build Options**: 
  - **Latest**: Downloads Oracle software automatically during build
  - **Slim**: Uses locally provided Oracle software (smaller build context)
- **Persistent Storage**: Data persists across container restarts using Docker volumes
- **Easy Configuration**: Customize credentials and settings via environment variables
- **Production-Ready**: Includes proper initialization, health checks, and automatic setup
- **Modern APEX**: Comes with Oracle APEX 24.2

## 🔧 Prerequisites

- Docker Engine 20.10+ or Docker Desktop
- At least 4GB of RAM allocated to Docker
- At least 15GB of free disk space
- Oracle Software (for `latest` slim builds)

### For Slim Builds Only

Download the following files and place them in the `build/` directory:

1. **Oracle Database XE 21c**: [oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm](https://www.oracle.com/database/technologies/xe-downloads.html)
2. **Oracle ORDS 25.3.1**: [ords-25.3.1.289.1312.zip](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
3. **Oracle APEX 24.2**: [apex_24.2.zip](https://www.oracle.com/tools/downloads/apex-downloads.html)

## 🚀 Quick Start

### Using Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/yourusername/oracle-apex-docker.git
cd oracle-apex-docker
```

2. Start the container:
```bash
docker compose up -d
```

3. Wait for initialization (first start takes 5-10 minutes):
```bash
docker compose logs -f oracle-apex
```

4. Access APEX at [http://localhost:8080/ords](http://localhost:8080/ords)

### Using Docker Run

```bash
docker run -d \
  --name oracle-apex \
  -p 1521:1521 \
  -p 8080:8080 \
  -e ORACLE_PWD="Oracle123456" \
  -e APEX_ADMIN_EMAIL="admin@example.com" \
  -e ORDS_PWD="Oracle123456" \
  -v apex_data:/opt/oracle/oradata \
  codjix/oracle-apex:latest
```

## 📦 Image Types

### Latest (Full Build)

The `latest` image downloads all Oracle software automatically during the Docker build process:

- **Pros**: Simpler build process, no manual downloads
- **Cons**: Larger build context, requires internet during build
- **Image Tag**: `codjix/oracle-apex:latest`

### Slim Build

The `slim` image requires you to manually download Oracle software and place it in the `build/` directory:

- **Pros**: Faster builds after initial setup, works offline
- **Cons**: Manual download step required, needs volume mount during setup
- **Image Tag**: `codjix/oracle-apex:slim`

## 🔨 Building the Image

The project includes a convenient build script:

### Build Latest Image

```bash
./build.sh latest
```

### Build Slim Image

1. Download required files to `build/` directory (see [Prerequisites](#for-slim-build-only))
2. Build the image:
```bash
./build.sh slim
```

### Build Script Options

```bash
./build.sh --help     # Show help
./build.sh --version  # Show version
```

### Manual Build (Alternative)

```bash
# Latest
docker buildx build -t codjix/oracle-apex:latest -f ./Dockerfile .

# Slim
docker buildx build -t codjix/oracle-apex:slim -f ./slim.Dockerfile .
```

## ⚙️ Configuration

Configure the container using environment variables in `compose.yaml` or via `-e` flags with `docker run`.

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ORACLE_PWD` | SYS/SYSTEM database password | `Oracle123456` | Yes |
| `APEX_ADMIN_EMAIL` | APEX admin email address | `admin@example.com` | Yes |
| `ORDS_PWD` | ORDS and APEX user passwords | `Oracle123456` | Yes |
| `ORACLE_SID` | Oracle System Identifier | `XE` | No |
| `ORACLE_PDB` | Pluggable Database name | `XEPDB1` | No |

### Ports

| Port | Service | Description |
|------|---------|-------------|
| `1521` | Oracle Database | SQL*Net listener for database connections |
| `8080` | ORDS/APEX | Web interface for APEX and REST APIs |

### Volumes

| Path | Description |
|------|-------------|
| `/opt/oracle/oradata` | Database files (persistent storage) |
| `/build` | Oracle software files (slim image only) |

## 📖 Usage

### Starting the Container

```bash
docker compose up -d
```

### Stopping the Container

```bash
docker compose down
```

### Viewing Logs

```bash
docker compose logs -f oracle-apex
```

### Restarting the Container

```bash
docker compose restart oracle-apex
```

### Accessing the Database via SQL*Plus

From inside the container:
```bash
docker compose exec oracle-apex sqlplus sys/Oracle123456@localhost:1521/XE as sysdba
```

From your host (requires Oracle Client):
```bash
sqlplus sys/Oracle123456@localhost:1521/XE as sysdba
```

### Connecting to PDB

```bash
sqlplus sys/Oracle123456@localhost:1521/XEPDB1 as sysdba
```

## 🌐 Accessing APEX

Once the container is running, access Oracle APEX through your web browser:

- **APEX Development**: [http://localhost:8080/ords](http://localhost:8080/ords)
- **APEX Administration**: [http://localhost:8080/ords/apex_admin](http://localhost:8080/ords/apex_admin)

### First Login

1. Navigate to [http://localhost:8080/ords](http://localhost:8080/ords)
2. Click on **"Administration Services"** or go to `/apex_admin`
3. Login with:
   - **Workspace**: `INTERNAL`
   - **Username**: `ADMIN`
   - **Password**: Value of `ORACLE_PWD` (default: `Oracle123456`)

## 🔐 Default Credentials

### APEX Workspace INTERNAL

- **Username**: `ADMIN`
- **Password**: `Oracle123456` (or your `ORACLE_PWD` value)
- **Email**: `admin@example.com` (or your `APEX_ADMIN_EMAIL` value)

### Oracle Database

- **SYS/SYSTEM Password**: `Oracle123456` (or your `ORACLE_PWD` value)
- **Connection String**: `localhost:1521/XE` (CDB) or `localhost:1521/XEPDB1` (PDB)

### APEX Schema Users

- **APEX_PUBLIC_USER**: Password set to `ORDS_PWD`
- **APEX_REST_PUBLIC_USER**: Password set to `ORDS_PWD`
- **APEX_LISTENER**: Password set to `ORDS_PWD`

> **⚠️ Security Warning**: Change default passwords in production environments!

## 💾 Data Persistence

Database files are stored in a Docker volume mounted at `/opt/oracle/oradata`. This ensures:

- Data persists across container restarts
- Data survives container removal
- Easy backup and restore capabilities

### Reset Database

To start fresh (⚠️ deletes all data):

```bash
docker compose down -v
docker compose up -d
```

## 🔍 Troubleshooting

### Container Exits Immediately

Check the logs:
```bash
docker compose logs oracle-apex
```

Common causes:
- Insufficient memory (increase Docker memory to 8GB+)
- Insufficient disk space
- Port conflicts (1521 or 8080 already in use)

### Slow First Start

The first container start takes 10-20 minutes as it:
1. Installs Oracle Database XE
2. Configures the database
3. Installs Oracle APEX
4. Configures ORDS
5. Creates admin user

Subsequent starts are much faster (~30 seconds).

### Slim Image: Missing Build Files

If using the slim image, ensure:
```bash
ls -lh build/
# Should show:
# apex.zip
# database.rpm
# ords.zip
```

And in `compose.yaml`, uncomment:
```yaml
volumes:
  - ./build:/build
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Ibrahim Megahed**
- Email: codjix@gmail.com
- GitHub: [@codjix](https://github.com/codjix)

## 🙏 Acknowledgments

- Oracle Corporation for Oracle Database XE, ORDS, and APEX
- The Oracle Linux team for the base image

## ⚠️ Disclaimer

This Docker image is for development and testing purposes. Oracle Database XE comes with its own license terms. Please review [Oracle's licensing](https://www.oracle.com/downloads/licenses/database-11g-express-license.html) before use.

For production use, consider Oracle's official container images or ensure compliance with Oracle's licensing requirements.
