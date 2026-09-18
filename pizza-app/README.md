# Pizza Order Tracker

A pizza ordering system built from three microservices and a web frontend.

## What's Inside

- **Order Service** (Port 3000): Receives pizza orders and coordinates with other services
- **Kitchen Service** (Port 3001): Checks availability and cooks pizzas
- **Delivery Service** (Port 3002): Assigns drivers for delivery
- **Frontend** (Port 8080): Simple web UI for ordering pizzas

## Architecture

```
┌─────────────┐
│   Browser   │
│  (Port 8080)│
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Order     │────▶│   Kitchen   │     │  Delivery   │
│  Service    │     │   Service   │     │   Service   │
│ (Port 3000) │     │ (Port 3001) │     │ (Port 3002) │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Running the App

```bash
docker compose up
```

Then open http://localhost:8080 and order a pizza.

To stop it:

```bash
docker compose down
```

## Watching What Happens

The terminal shows all four services interleaved:

```
order-service    | Order received: PIZZA-123...
kitchen-service  | Starting to cook...
delivery-service | Assigning driver...
```

One service on its own:

```bash
docker compose logs -f kitchen-service
```

## Observability

All three Node services are instrumented with OpenTelemetry auto-instrumentation
(HTTP, Express, and outgoing Axios calls) and export traces and metrics to a
local OpenTelemetry Collector, which forwards them to Dash0.

1. Create `pizza-app/.env` from the template (`cp .env.template .env`) and fill
   in `DASH0_AUTH_TOKEN` and `DASH0_ENDPOINT` for your Dash0 organization.
2. Run `docker compose up` as usual — the `otel-collector` service starts
   alongside the app and each Node service ships its telemetry to it over
   OTLP/HTTP (`otel-collector:4318`).
3. Because trace context propagates automatically across the HTTP calls
   between `order-service`, `kitchen-service`, and `delivery-service`, a single
   pizza order shows up in Dash0 as one connected trace.

The Dash0 token and endpoint are only ever referenced via environment
variables (`${DASH0_AUTH_TOKEN}`, `${DASH0_ENDPOINT}`) — they are never
written into a committed file.

## Failure Modes You Can Switch On

### Slow Kitchen (Oven is Broken)
```bash
SLOW_KITCHEN=true docker compose up
```

Every pizza takes about five seconds longer to cook.

### No Drivers Available
```bash
NO_DRIVERS=true docker compose up
```

Delivery has nobody to assign, so orders fail.

## Services Overview

### Order Service
- Receives orders from the frontend
- Calls Kitchen Service to check availability and cook
- Calls Delivery Service to assign a driver
- Returns order confirmation

### Kitchen Service
- Checks if kitchen is available
- Simulates cooking time
- Can be configured to be slow (SLOW_KITCHEN=true)

### Delivery Service
- Finds available drivers
- Assigns driver to order
- Can be configured to have no drivers (NO_DRIVERS=true)

### Frontend
- Simple HTML form
- Sends orders to Order Service
- Displays confirmation

## Tech Stack

- **Node.js** - Runtime
- **Express** - Web framework
- **Axios** - HTTP client
- **Docker** - Containerization

## Ports

- `3000` - Order Service
- `3001` - Kitchen Service
- `3002` - Delivery Service
- `8080` - Frontend
