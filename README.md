# Store Stock API

API REST para la gestión de stock e inventario de tiendas pequeñas. Permite administrar **tiendas, sucursales, categorías, productos y stock por sucursal**, con autenticación JWT, control de acceso basado en roles y exportación de inventario a CSV.

Este repositorio contiene únicamente el **backend**. El frontend vive en un repositorio separado.

| Repositorio | Enlace |
|-------------|--------|
| **Backend (API)** | https://github.com/sambeck87/StoreStockAPI |
| **Frontend** | https://github.com/sambeck87/StoreStockFront |

---

## 🧰 Puesta en marcha para tu equipo

### 1. Clonar los repositorios

```bash
git clone https://github.com/sambeck87/StoreStockAPI.git store-stock-api
git clone https://github.com/sambeck87/StoreStockFront.git store-stock-front
```

### 2. Configurar el backend

#### Requisitos

- Ruby 3.4.7
- PostgreSQL
- Redis
- Bundler

#### Variables de entorno

Copia el archivo de ejemplo y completa cada valor según tu entorno. **Nunca compartas valores reales** (contraseñas, tokens) ni subas tu `.env` al repositorio.

```bash
cp .env.example .env   # crear el archivo .env si no existe
```

Variables que debe declarar el equipo, y su función:

| Variable | Función |
|----------|---------|
| `DATABASE_URL` | URL completa de conexión a PostgreSQL (usada en producción) |
| `STORE_STOCK_API_DATABASE_NAME` | Nombre de la base de datos de producción |
| `STORE_STOCK_API_DATABASE_USERNAME` | Usuario de PostgreSQL |
| `STORE_STOCK_API_DATABASE_PASSWORD` | Contraseña del usuario de PostgreSQL |
| `DB_HOST` | Host donde corre PostgreSQL |
| `REDIS_URL` | URL de conexión a Redis (cola de Sidekiq) |
| `SMTP_ADDRESS` | Servidor SMTP saliente para el envío de correos |
| `SMTP_PORT` | Puerto del servidor SMTP |
| `SMTP_USERNAME` | Usuario de autenticación SMTP |
| `SMTP_PASSWORD` | Contraseña de autenticación SMTP |
| `SMTP_CA_FILE` | Certificado CA para la conexión SMTP segura |
| `MAILER_FROM` | Dirección remitente de los correos (confirmación, reset) |
| `APP_HOST` | Host público de la API (se usa en los enlaces de los correos) |
| `FRONTEND_URL` | URL del frontend (se usa en los enlaces de confirmación y restablecimiento de contraseña) |
| `CORS_ORIGINS` | Orígenes permitidos para CORS, separados por coma (e.g. la URL de tu frontend) |
| `RAILS_MASTER_KEY` | Clave maestra de Rails para descifrar `config/credentials.yml.enc` |
| `WORKER` | Si es `true`, el contenedor arranca Sidekiq en lugar de Puma |

> Variables opcionales: `RAILS_MAX_THREADS` (hilos de Puma), `PORT` (puerto del servidor), `RAILS_LOG_LEVEL` (nivel de log).

#### Instalar y arrancar

```bash
bundle install
rails db:prepare        # crea y migra la base de datos
bin/dev                 # arranca Puma + Sidekiq (ver Procfile.dev)
```

La API queda disponible en `http://localhost:3000` y el estado en `GET /up`.

### 3. Configurar el frontend

Sigue las instrucciones del [README del frontend](https://github.com/sambeck87/StoreStockFront). Verifica que la `FRONTEND_URL` del backend y la URL de la API que apunta el frontend coincidan con tu entorno local.

### 4. Pruebas

```bash
bundle exec rspec
```

La suite cubre modelos (validaciones y asociaciones), controladores (peticiones autenticadas con JWT) y servicios (lógica de negocio), con FactoryBot y Shoulda Matchers.

---

## ✨ Funcionalidades

- **Autenticación y seguridad**
  - Registro con confirmación por email y restablecimiento de contraseña
  - Sesiones basadas en **JWT** (Bearer token)
  - Auditoría de `created_by` / `updated_by` en categorías e ítems

- **Multi-tienda y multi-sucursal**
  - Jerarquía `Store → Branch → BranchItem`
  - Stock individual por sucursal (`branch_items`)
  - Búsqueda por sucursales accesibles según permisos

- **Control de acceso granular**
  - Roles por sucursal con permisos en JSON (`Role#allows?`)
  - Permisos globales (`GlobalPermission`)
  - Super admin y managers por sucursal
  - Políticas de autorización (`ApplicationPolicy`)

- **Catálogo**
  - Categorías con ítems (productos) y unidades de medida
  - Categorías únicas por tienda, ítems únicos por tienda

- **Inventario y exportación**
  - Vista consolidada de inventario con paginación
  - Exportación a **CSV** en segundo plano (Sidekiq) con descarga y expiración automática
  - Limpieza periódica de exportaciones vencidas (cron diario)

- **API limpia y consistente**
  - Endpoints versionados bajo `/api/v1`
  - Respuestas serializadas con convención común y manejo centralizado de errores
  - Paginación estándar

---

## 🛠 Stack tecnológico

| Capa | Tecnología |
|------|------------|
| Lenguaje | Ruby 3.4.7 |
| Framework | Rails 8.1.1 (API-only) |
| Base de datos | PostgreSQL |
| Servidor | Puma + Thruster |
| Tareas en segundo plano | Sidekiq (+ sidekiq-cron) |
| Caché / colas | Redis |
| Auth | JWT + bcrypt |
| Testing | RSpec, FactoryBot, Shoulda Matchers, Database Cleaner |
| Calidad | RuboCop (omakase), Brakeman, Bundler Audit |
| Despliegue | Docker + Kamal |

---

## 🏗 Arquitectura

El proyecto sigue una arquitectura **service-object + query objects** por recurso:

```
app/
├── controllers/api/v1/   # Endpoints versionados (REST)
├── models/               # ActiveRecord: User, Store, Branch, Category, Item, BranchItem, Role, ...
├── policies/             # ApplicationPolicy y políticas por recurso
├── services/             # Lógica de negocio: CreateItem, UpdateItem, DeleteStore, OnboardStore, ...
├── queries/              # Consultas indexables por recurso y permisos
├── serializers/          # Serialización uniforme de respuestas
├── responses/            # Contratos de respuesta (e.g. SessionResponse)
└── jobs/                 # Sidekiq: InventoryExportJob, CleanupInventoryExportsJob
```

### Modelo de dominio

```
Store ── has_many ──> Branch ── has_many ──> BranchItem (stock por sucursal)
  │                      │
  ├──> Category ──> Item ────────────────> BranchItem
  ├──> Role (permisos por tienda)
  └──> GlobalPermission

User ── has_many ──> BranchUser (rol por sucursal) ──> Branch
```

---

## 🐳 Despliegue (Docker)

```bash
docker build -t store-stock-api .
docker run --env-file .env -p 80:80 store-stock-api
```

El contenedor arranca Puma + Thruster para la API, o Sidekiq si `WORKER=true`. Para despliegues con Kamal se puede usar la configuración de `config/deploy.yml`.

---

## 📡 Endpoints principales (`/api/v1`)

| Recurso | Endpoints |
|---------|-----------|
| Sesión | `POST /sessions` |
| Registro | `POST /registration` |
| Confirmaciones | `PATCH /confirmations/:id` |
| Contraseña | `POST /passwords/reset`, `PUT /passwords/update` |
| Usuarios | `GET/POST/PATCH/DELETE /users` |
| Tiendas | `GET/POST/PATCH/DELETE /stores` |
| Sucursales | `GET/POST/PATCH/DELETE /branches` |
| Categorías | `GET/POST/PATCH/DELETE /categories` |
| Ítems | `GET/POST/PATCH/DELETE /categories/:category_id/items` |
| Inventario | `GET /inventory` |
| Exportaciones | `POST /inventory/exports`, `GET /inventory/exports/:id/download` |

---

## 📄 Licencia

Proyecto privado de uso interno.
